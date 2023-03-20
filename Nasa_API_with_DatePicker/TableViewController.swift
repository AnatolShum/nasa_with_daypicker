//
//  TableViewController.swift
//  Nasa_API_with_DatePicker
//
//  Created by Anatolii Shumov on 24/02/2023.
//

import UIKit


class TableViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewWithImage: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let dateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    let datePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let descriptionLabelIndexPath = IndexPath(row: 0, section: 2)
    let copyrightLabelIndexPath = IndexPath(row: 1, section: 2)
    
    var date: String = ""
    
    let spaceBetweenSections = 2.0
    
    var isDatePickerVisible: Bool = false
    {
        didSet {
            datePicker.isHidden = !isDatePickerVisible
        }
    }
    
    let photoInfoController = PhotoInfoController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let midnightToday = Date()
        datePicker.maximumDate = midnightToday + 1
        datePicker.date = midnightToday
        
        updateDateView()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecofnizer))
                        pinchGesture.delegate = self
                viewWithImage.addGestureRecognizer(pinchGesture)
        
        title = ""
        imageView.image = UIImage(systemName: "photo.on.rectangle")
        descriptionLabel.text = ""
        copyrightLabel.text = ""
        
        updateDateView()
        
        Task {
            do {
                let photoInfo = try await photoInfoController.fetchPhotoInfo()
                updateUI(with: photoInfo)
            } catch {
                updateUI(with: error)
            }

        }
        
    }
    
    @objc func pinchRecofnizer(recognizer: UIPinchGestureRecognizer) {

            if recognizer.state == .began || recognizer.state == .changed {
            self.view.bringSubviewToFront(viewWithImage)
            recognizer.view?.transform = (recognizer.view?.transform)!.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1.0
        }
            
            if recognizer.state == .ended {
                self.viewWithImage.transform = CGAffineTransform.identity
            }
        }
    

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateView()
    }
    
    func updateDateView() {
        dateLabel.text = datePicker.date.formatted(date: .long, time: .omitted)
        self.datePicker.timeZone = TimeZone (secondsFromGMT:0)
        date = datePicker.date.formatted(.iso8601
            .year().month().day() )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
            case datePickerCellIndexPath where
            isDatePickerVisible == false:
            return 0
        case descriptionLabelIndexPath:
            return UITableView.automaticDimension
        case copyrightLabelIndexPath:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
 
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerCellIndexPath:
            return 216
        case descriptionLabelIndexPath:
            return UITableView.automaticDimension
        case copyrightLabelIndexPath:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == dateLabelCellIndexPath {
            isDatePickerVisible.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
            catchADay()
            if indexPath == dateLabelCellIndexPath && isDatePickerVisible == false {
                Task {
                    do {
                        let photoInfo = try await photoInfoController.fetchPhotoInfo()
                        updateUI(with: photoInfo)
                    } catch {
                        updateUI(with: error)
                    }
                    
                }
            }
        }
    }

    
    func updateUI(with photoInfo: PhotoInfo) {
        Task {
            do {
                let image = try await photoInfoController.fetchImage(from: photoInfo.url)
                title = photoInfo.title
                imageView.image = image
                descriptionLabel.text = photoInfo.description
                copyrightLabel.text = photoInfo.copyright
                tableView.reloadData()
            } catch {
                updateUI(with: error)
            }
        }
    }
    
    func updateUI(with error: Error) {
        title = "Error Fetching Photo"
        imageView.image = UIImage(systemName: "exclamationmark.octagon")
        descriptionLabel.text = error.localizedDescription
        copyrightLabel.text = ""
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(spaceBetweenSections)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(spaceBetweenSections)
    }
    
}


extension TableViewController: UIGestureRecognizerDelegate {
    
}


extension TableViewController: DateDelegate {
    func catchADay() {
        photoInfoController.selectedDate = date
    }
    
    
}


