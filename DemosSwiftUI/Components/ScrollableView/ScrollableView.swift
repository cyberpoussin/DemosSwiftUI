import SwiftUI



struct ScrollableView<Content: View>: UIViewControllerRepresentable {
    // MARK: - Type
    typealias UIViewControllerType = UIScrollViewController<Content>

    // MARK: - Properties
    var offsetInside: Binding<CGPoint>
    @ObservedObject var positionController: PositionController
    var animationDuration: TimeInterval = 0
    var content: () -> Content
    var showsScrollIndicator: Bool
    let headerHeight: CGFloat

    // MARK: - Init

    init(offsetInside: Binding<CGPoint>, positionController: PositionController, animationDuration: TimeInterval = 0, showsScrollIndicator: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.offsetInside = offsetInside
        self.positionController = positionController
        self.animationDuration = animationDuration
        self.showsScrollIndicator = showsScrollIndicator
        self.headerHeight = 0
        self.content = content
    }

    // MARK: - Updates
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {
        let vc = UIScrollViewController(rootView: content(), offsetInside: offsetInside, parent: self, headerHeight: headerHeight)
        vc.scrollView.showsVerticalScrollIndicator = showsScrollIndicator
        vc.scrollView.showsHorizontalScrollIndicator = showsScrollIndicator
        vc.scrollView.contentInsetAdjustmentBehavior = .never
        vc.hostingController.rootView = content()
        vc.view.layoutIfNeeded()
        return vc
    }

    func updateUIViewController(_ viewController: UIViewControllerType, context: UIViewControllerRepresentableContext<Self>) {
        
        viewController.updateContent(content)
        let duration: TimeInterval = self.duration(viewController)
        guard duration != .zero else {
            viewController.scrollView.contentOffset = offsetInside.wrappedValue
            return
        }
        UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            viewController.scrollView.contentOffset = self.offsetInside.wrappedValue
        }, completion: nil)
    }

    // Cette fonction permet de calculer la 'duration' de l'animation si on influe sur le offsetInside depuis l'extérieur (par exemple quand on remet à zéro quand on dragge le titre de la sheet)
    private func duration(_ viewController: UIViewControllerType) -> TimeInterval {
        var diff: CGFloat = 0
        diff = abs(viewController.scrollView.contentOffset.y - offsetInside.wrappedValue.y)
        if diff == 0 {
            return .zero
        }
        let percentageMoved = diff / UIScreen.main.bounds.height
        return animationDuration * min(max(TimeInterval(percentageMoved), 0.25), 1)
    }
}

final class UIScrollViewController<Content: View>: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, ObservableObject {
    // MARK: - Properties
    var offsetInside: Binding<CGPoint>
    var pc: PositionController

    var oldScroll: CGPoint
    var initialY: CGFloat
    let headerHeight: CGFloat
    let hostingController: UIHostingController<Content>
    // C'est ici qu'on customize notre propre recognizer pour les drags effectués sur la ScrollView
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = true
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.isUserInteractionEnabled = true

        // ici on gère le DRAG de la ScrollView (faut il scroller l'intérieur ou renvoyer l'info à l'extérieur)
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleDrag(_:)))

        // ici on gère le TAP de la ScrollView (faut-il scroller l'intérieur ou renvoyer l'info à l'extérieur)
        let singleTap = CustomLongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        singleTap.pc = pc
        
        scrollView.panGestureRecognizer.delaysTouchesBegan = true
        scrollView.panGestureRecognizer.cancelsTouchesInView = false

        singleTap.delaysTouchesBegan = false
        singleTap.minimumPressDuration = 0
        singleTap.cancelsTouchesInView = false
        singleTap.delegate = self
        scrollView.addGestureRecognizer(singleTap)
        return scrollView
    }()

    // MARK: - Init

    init(rootView: Content, offsetInside: Binding<CGPoint>, parent: ScrollableView<Content>, headerHeight: CGFloat) {
        self.offsetInside = offsetInside
        self.pc = parent.positionController
        oldScroll = CGPoint(x: 0, y: 0)
        hostingController = UIHostingController<Content>(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        initialY = pc.totalDrag.y
        self.headerHeight = headerHeight
        
        
        super.init(nibName: nil, bundle: nil)
    }

    /* MARK: handlePress
            fonction pour chopper le TAP de l'utilisateur, et renvoyer l'info à
     l'extérieur pour par exemple interropre une animation en cours */
    @objc private func handlePress(_ recognizer: UILongPressGestureRecognizer) {
        let touchGlobal = recognizer.location(in: nil)
        let touchInView = recognizer.location(in: view)
        let globalPoint = view.convert(view.frame.origin, to: nil)
        let bizarreDiff = globalPoint.y - initialY
        let touch = CGPoint(x: 0, y: touchGlobal.y - touchInView.y - pc.statusBarHeight)
        // attention à la différence de l'encoche, le fameux 44
        switch recognizer.state {
        case .began:
            print("handlePress : le 44 ? globalPoint :\(bizarreDiff) \(touchGlobal.y) - \(touchInView.y) = \(touchGlobal.y - touchInView.y)")
            // on gère ce stop finalement dans la vue. 
            //pc.stop = touch
            pc.isScrolled = true
        case .ended:
            pc.isScrolled = false
        default:
            break
        }
    }

    @objc internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /* MARK: handleDrag
     Ici on intercepte le Drag car il faut décider si on scroll vraiment la scrollView ou si on fait remonter l'info
     */
    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let deltaY = recognizer.translation(in: view).y
        let velocity = recognizer.velocity(in: view)

        switch recognizer.state {
        case .began:
            if scrollView.contentOffset.y <= 0 {
                oldScroll.y = 0
            } else if scrollView.contentOffset.y > scrollView.contentSize.height {
                oldScroll.y = scrollView.contentSize.height
            } else {
                oldScroll.y = scrollView.contentOffset.y
            }
            pc.isScrolled = true

        case .changed:
            if scrollView.contentOffset.y <= 0 {
                if scrollView.contentOffset.y < 0 {
                    AnimatorScroll.shared.animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
                        self.scrollView.contentOffset.y = -1
                    }
                    AnimatorScroll.shared.animator.startAnimation()
                } else {
                    pc.totalDrag.y = pc.oldOffset.y + deltaY - oldScroll.y
                }
            }
//        if self.totalDrag.wrappedValue.y < topLimit {
//            pc.isScrollable = true
//        } else {
//            pc.isScrollable = false
//        }
        case .failed, .ended, .cancelled:
            if scrollView.contentOffset.y <= 0 {
                pc.velocity = velocity

            } else {
                pc.velocity.y = 0
            }
            pc.oldOffset.y = pc.totalDrag.y
            pc.isScrolled = false

        default:
            break
        }
    }

    // MARK: - Update

    func updateContent(_ content: () -> Content) {
        hostingController.rootView = content()
        //let width = hostingController.view.intrinsicContentSize.width
        //var contentSize = self.hostingController.view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        var contentSize: CGSize = hostingController.view.intrinsicContentSize
        // contentSize.height += topLimit
        if contentSize.height < UIScreen.main.bounds.height {
            contentSize.height = UIScreen.main.bounds.height + 1
        }
        contentSize.width = pc.sheetWidth

        // On ajoute le contenu que si ça n'a pas été déjà fait
        if scrollView.subviews.isEmpty {
            scrollView.addSubview(hostingController.view)
            hostingController.view.frame.size = contentSize
        } else {
            scrollView.subviews[0].removeFromSuperview()
            scrollView.addSubview(hostingController.view)
            hostingController.view.frame.size = contentSize

        }
        // Par contre on adapte la taille du contenant
        scrollView.contentSize = contentSize
        //createConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(scrollView)
//        pinEdges(of: scrollView, to: view)
//
//        hostingController.willMove(toParent: self)
//        scrollView.addSubview(hostingController.view)
//        pinEdges(of: hostingController.view, to: scrollView)
//        hostingController.didMove(toParent: self)
//    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        view.addSubview(scrollView)
        createConstraints()
        view.layoutIfNeeded()
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.endEditing(true)

        offsetInside.wrappedValue = scrollView.contentOffset
        scrollView.showsVerticalScrollIndicator = true

        // Si on a atteint le haut et que l'user continue de dragger on ne fait pas la résistance élastique, car on doit descendre directement la sheet
        if pc.isScrollable && pc.isScrolled && scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }

        // Si le HandleDrag n'a pas donné l'ordre de scroller le contenu hé bien on reste en place.
        if !pc.isScrollable {
            scrollView.contentOffset.y = 0
            scrollView.showsVerticalScrollIndicator = false
        }
    }

    // MARK: - Constraints

    fileprivate func createConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}


import UIKit.UIGestureRecognizerSubclass

// bizaremment c'est ce recognizer custom qui permet de faire passer le TAP avant le DRAG sans délai !
class CustomLongPressGestureRecognizer: UILongPressGestureRecognizer {
    var pc: PositionController?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if pc?.isScrolled == false {
            let touchGlobal = touches.first!.location(in: nil)
            let touchInView = touches.first!.location(in: view)

            // On pourrait renvoyer l'info de l'emplacement du TAP ici, mais on prefère le faire dans le handlePress

            // let touch = CGPoint(x: 0, y: touchGlobal.y - touchInView.y + headerHeight/2)
            // attention à la différence de l'encoche, le fameux 44 ou  - headerHeight
            print("touchesBegan le 44 ? \(touchGlobal.y) \(touchInView.y)")
            // pc?.stop = touch
            pc?.isScrolled = true
        }
    }
}
