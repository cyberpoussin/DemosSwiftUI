//
//  SwiftUIView19.swift
//  DemosSwiftUI
//
//  Created by Admin on 26/08/2021.
//

import SwiftUI


struct CustomScrollView: View {
    @State private var offset: CGPoint = CGPoint(x: 0, y: 200)
    let texts: [String] = (1 ... 100).map { _ in String.random(length: Int.random(in: 6 ... 20)) }
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                UIScrollViewWrapper(offset: $offset) { //
                    VStack {
                        Text("Start")
                            .foregroundColor(.red)
                        ForEach(texts, id: \.self) { text in
                            Text(text)
                        }
                    }
                    .padding(.top, 40)

                    .frame(width: geo.size.width)
                }
                .navigationBarTitle("Test")
            }
            HStack {
                Text(offset.debugDescription)
                Button("add") {
                    offset.y += 100
                }
            }
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }
}

class UIScrollViewViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        v.alwaysBounceVertical = true
        return v
    }()

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        pinEdges(of: scrollView, to: view)

        hostingController.willMove(toParent: self)
        scrollView.addSubview(hostingController.view)
        pinEdges(of: hostingController.view, to: scrollView)
        hostingController.didMove(toParent: self)
    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }
}

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    var content: () -> Content
    @Binding var offset: CGPoint
    init(offset: Binding<CGPoint>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        _offset = offset
    }

    func makeCoordinator() -> Controller {
        return Controller(parent: self)
    }

    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController()
        vc.scrollView.contentInsetAdjustmentBehavior = .never
        vc.hostingController.rootView = AnyView(content())
        vc.view.layoutIfNeeded()
        vc.scrollView.contentOffset = offset
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(content())
        viewController.scrollView.contentOffset = offset
    }

    class Controller: NSObject, UIScrollViewDelegate {
        var parent: UIScrollViewWrapper<Content>
        init(parent: UIScrollViewWrapper<Content>) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset
        }
    }
}

struct SwiftUIView19_Previews: PreviewProvider {
    static var previews: some View {
        CustomScrollView()
    }
}
