import MapKit
import UIKit

class TrainAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "TrainAnnotationView"

    private let containerView = UIView()
    private let trainIconView = UIImageView()
    private let typeLabel = UILabel()
    private let numberLabel = UILabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Configure container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Configure train icon
        trainIconView.translatesAutoresizingMaskIntoConstraints = false
        trainIconView.contentMode = .scaleAspectFit
        containerView.addSubview(trainIconView)

        // Configure type label (IC, SPR, etc.)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        typeLabel.textColor = .white
        typeLabel.textAlignment = .center
        typeLabel.backgroundColor = .nsBlue
        typeLabel.layer.cornerRadius = 8
        typeLabel.clipsToBounds = true
        containerView.addSubview(typeLabel)

        // Configure number label (rit number)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        numberLabel.textColor = .nsBlue
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = .nsYellow
        numberLabel.layer.cornerRadius = 6
        numberLabel.clipsToBounds = true
        containerView.addSubview(numberLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 40),
            containerView.heightAnchor.constraint(equalToConstant: 60),

            trainIconView.topAnchor.constraint(equalTo: containerView.topAnchor),
            trainIconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            trainIconView.widthAnchor.constraint(equalToConstant: 32),
            trainIconView.heightAnchor.constraint(equalToConstant: 32),

            typeLabel.topAnchor.constraint(equalTo: trainIconView.bottomAnchor, constant: 2),
            typeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            typeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            typeLabel.heightAnchor.constraint(equalToConstant: 16),

            numberLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 2),
            numberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            numberLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            numberLabel.heightAnchor.constraint(equalToConstant: 14)
        ])

        // Set frame size
        frame = CGRect(x: 0, y: 0, width: 60, height: 80)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trainIconView.image = nil
        trainIconView.transform = .identity
        typeLabel.text = nil
        numberLabel.text = nil
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard let annotation = annotation as? TrainAnnotation else { return }
        let train = annotation.train

        // Set train icon based on type
        let iconName: String
        if train.typeCode.contains("IC") {
            iconName = "train.side.front.car" // Intercity icon
        } else if train.typeCode.contains("SPR") {
            iconName = "tram.fill" // Sprinter icon (use tram as proxy)
        } else {
            iconName = "train.side.front.car" // Default train icon
        }

        // Create colored icon
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image = UIImage(systemName: iconName, withConfiguration: config)?
            .withTintColor(.nsYellow, renderingMode: .alwaysOriginal)
        trainIconView.image = image

        // Set type label
        typeLabel.text = train.typeCode
        typeLabel.sizeToFit()
        typeLabel.frame.size.width = max(typeLabel.frame.size.width + 8, 30)

        // Set number label (train number)
        numberLabel.text = String(train.trainNumber)
        numberLabel.sizeToFit()
        numberLabel.frame.size.width = max(numberLabel.frame.size.width + 6, 30)

        // Enable tvOS focus
        if #available(tvOS 13.0, *) {
            // Make annotation focusable on tvOS
        }
    }
}
