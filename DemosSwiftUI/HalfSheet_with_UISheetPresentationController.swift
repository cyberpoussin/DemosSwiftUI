//
//  SwiftUIView13.swift
//  DemosSwiftUI
//
//  Created by Admin on 21/08/2021.
//

import Combine
import MapKit
import SwiftUI

struct TestHalfSheet: View {
    @State private var text: String = ""
    @State private var showSheet: Bool = false
    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(.red)
                Text("Show sheet")
                    .onTapGesture {
                        showSheet.toggle()
                    }
            }
        }
        .halfSheet(showSheet: $showSheet){
            Rectangle()
        } onDismiss: {
            print("dismiss")
        }

    }
}

extension View {
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder content sheetView: @escaping () -> SheetView, onDismiss: (() -> Void)? = nil) -> some View {
        return background(
            HalfSheet(sheetView: sheetView(), showSheet: showSheet, onDismiss: onDismiss ?? {})
        )
    }
}

// UIKit extension
struct HalfSheet<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    let controller = UIViewController()
    @Binding var showSheet: Bool
    var onDismiss: () -> Void
    @State private var cancellable: AnyCancellable?
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        print("update")
        let presenting = uiViewController.presentedViewController != nil
        if showSheet && !presenting {
            let sheetController = CustomHostingController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        } else if !showSheet && presenting {
            uiViewController.dismiss(animated: true)
        }
    }

    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: HalfSheet

        init(parent: HalfSheet) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onDismiss()
        }
    }
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    var cancellable: AnyCancellable?
    override func viewDidLoad() {
        view.backgroundColor = .clear
        // setting presentation controller properties
        if #available(iOS 15.0, *) {
            if let presentationController = presentationController as? UISheetPresentationController {
                presentationController.detents = [
                    .medium(),
                    .large(),
                ]
                //
                presentationController.smallestUndimmedDetentIdentifier = nil
                //
                presentationController.prefersGrabberVisible = true
                presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
                presentationController.prefersEdgeAttachedInCompactHeight = true
                presentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                presentationController.selectedDetentIdentifier = .medium
                //                presentationController.preferredCornerRadius = 5.0
                
                cancellable = presentationController.publisher(for: \.selectedDetentIdentifier).sink(receiveValue: {value in
                    print("le voilà : \(value)")
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
}


// MARK: Alternative :
@available(iOS 15.0, *)
struct CustomSheet_UI<Content: View>: UIViewControllerRepresentable {
    let content: Content
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool

    init(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        _isPresented = isPresented
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CustomSheetViewController<Content> {
        let vc = CustomSheetViewController(coordinator: context.coordinator, detents: detents, smallestUndimmedDetentIdentifier: smallestUndimmedDetentIdentifier, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: { content })
        return vc
    }

    func updateUIViewController(_ uiViewController: CustomSheetViewController<Content>, context: Context) {
        print("lol")
        if isPresented {
            uiViewController.presentModalView()
        } else {
            uiViewController.dismissModalView()
        }
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var parent: CustomSheet_UI
        init(_ parent: CustomSheet_UI) {
            self.parent = parent
        }

        // Adjust the variable when the user dismisses with a swipe
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if parent.isPresented {
                parent.isPresented = false
            }
        }
    }
}

@available(iOS 15.0, *)
class CustomSheetViewController<Content: View>: UIViewController {
    let content: Content
    let coordinator: CustomSheet_UI<Content>.Coordinator
    let detents: [UISheetPresentationController.Detent]
    let smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool

    init(coordinator: CustomSheet_UI<Content>.Coordinator, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], smallestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = .medium, prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.coordinator = coordinator
        self.detents = detents
        self.smallestUndimmedDetentIdentifier = smallestUndimmedDetentIdentifier
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        super.init(nibName: nil, bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func dismissModalView() {
        dismiss(animated: true, completion: nil)
    }

    func presentModalView() {
        let hostingController = UIHostingController(rootView: content)

        hostingController.modalPresentationStyle = .popover
        hostingController.presentationController?.delegate = coordinator as UIAdaptivePresentationControllerDelegate
        if let hostPopover = hostingController.popoverPresentationController {
            hostPopover.sourceView = super.view
            let sheet = hostPopover.adaptiveSheetPresentationController
            sheet.detents = detents
            sheet.smallestUndimmedDetentIdentifier =
                smallestUndimmedDetentIdentifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge =
                prefersScrollingExpandsWhenScrolledToEdge
            sheet.prefersEdgeAttachedInCompactHeight =
                prefersEdgeAttachedInCompactHeight
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        if presentedViewController == nil {
            present(hostingController, animated: true, completion: nil)
        }
    }
}

struct SwiftUIView13_Previews: PreviewProvider {
    static var previews: some View {
        TestHalfSheet()
    }
}
