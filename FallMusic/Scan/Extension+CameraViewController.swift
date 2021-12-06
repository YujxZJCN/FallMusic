import UIKit
import AVFoundation
import Photos

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        self.savePhotoLibrary(image: image)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            let videoRecorded = outputFileURL as URL
            UISaveVideoAtPathToSavedPhotosAlbum(videoRecorded.path, nil, nil, nil)
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
//        
//        dismiss(animated: false) {
//            guard let viewController = UIStoryboard(name: "Main", bundle: nil)
//                .instantiateViewController(identifier: "PhotoView") as? PhotoViewController else { return }
//
//            viewController.modalPresentationStyle = .fullScreen
//            viewController.selectedImage = image
//            self.present(viewController, animated: false, completion: nil)
//        }
    }
}
