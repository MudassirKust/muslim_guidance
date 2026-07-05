import Foundation
import google_mobile_ads
import GoogleMobileAds

class NativeAdFactory: FLTNativeAdFactory {

    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable : Any]? = nil
    ) -> GADNativeAdView? {

        let adView = GADNativeAdView()
        adView.backgroundColor = .white

        // CHANGED: clip the ad view itself so nothing can ever render outside
        // the 280pt box Flutter gives it, even if a future edit breaks the math again.
        adView.clipsToBounds = true

        // Container
        let container = UIStackView()
        container.axis = .vertical
        // CHANGED: spacing reduced from 8 -> 6 to save vertical space (3 gaps saved 6pt total)
        container.spacing = 6
        container.translatesAutoresizingMaskIntoConstraints = false
        // CHANGED: clip the container too, belt-and-suspenders with adView.clipsToBounds
        container.clipsToBounds = true
        adView.addSubview(container)

        NSLayoutConstraint.activate([
            // CHANGED: top/bottom padding reduced from 10 -> 8 to save 4pt total
            container.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 10),
            container.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -10)
        ])

        // 1. Media view (top)
        let mediaView = GADMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        // CHANGED: height reduced from 150 -> 130 (not 120). AdMob requires
        // AT LEAST 120x120pt for video media views - setting it to exactly 120
        // triggers a "MediaView is too small for video" warning because of
        // floating-point rounding during layout. 130 gives safe headroom
        // above the minimum while still saving 20pt vs the original 150.
        mediaView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        container.addArrangedSubview(mediaView)
        adView.mediaView = mediaView

        // 2. Icon + headline + badge/stars row
        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center
        container.addArrangedSubview(topRow)

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        topRow.addArrangedSubview(iconView)
        adView.iconView = iconView

        let textColumn = UIStackView()
        textColumn.axis = .vertical
        textColumn.spacing = 2
        topRow.addArrangedSubview(textColumn)

        let headlineLabel = UILabel()
        headlineLabel.font = .boldSystemFont(ofSize: 13)
        headlineLabel.textColor = .black
        headlineLabel.numberOfLines = 1
        textColumn.addArrangedSubview(headlineLabel)
        adView.headlineView = headlineLabel

        let badgeRow = UIStackView()
        badgeRow.axis = .horizontal
        badgeRow.spacing = 6
        badgeRow.alignment = .center
        textColumn.addArrangedSubview(badgeRow)

        let adBadge = UILabel()
        adBadge.text = "Ad"
        adBadge.font = .systemFont(ofSize: 9)
        adBadge.textColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1) // #4CAF50
        adBadge.layer.borderColor = adBadge.textColor.cgColor
        adBadge.layer.borderWidth = 1
        adBadge.layer.cornerRadius = 2
        adBadge.textAlignment = .center
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.widthAnchor.constraint(equalToConstant: 22).isActive = true
        adBadge.heightAnchor.constraint(equalToConstant: 14).isActive = true
        badgeRow.addArrangedSubview(adBadge)

        let starsLabel = UILabel() // simple star text instead of RatingBar
        starsLabel.font = .systemFont(ofSize: 11)
        starsLabel.textColor = UIColor(red: 1, green: 0.757, blue: 0.027, alpha: 1) // #FFC107
        badgeRow.addArrangedSubview(starsLabel)
        // we'll fill starsLabel manually below (no native AdStarRatingView equivalent label, store ref)

        // 3. Body text
        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 12)
        bodyLabel.textColor = UIColor(white: 0.33, alpha: 1)
        // CHANGED: numberOfLines reduced from 2 -> 1 to save another ~16pt of height.
        bodyLabel.numberOfLines = 1
        container.addArrangedSubview(bodyLabel)
        adView.bodyView = bodyLabel

        // 4. CTA button
        let ctaButton = UIButton(type: .system)
        ctaButton.backgroundColor = UIColor(red: 0.184, green: 0.620, blue: 0.573, alpha: 1) // #2F9E92
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        ctaButton.layer.cornerRadius = 6
        ctaButton.isUserInteractionEnabled = false // GADNativeAdView handles taps
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        // CHANGED: height reduced from 50 -> 42 to save another 8pt.
        ctaButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        container.addArrangedSubview(ctaButton)
        adView.callToActionView = ctaButton

        // ---- Populate content ----
        headlineLabel.text = nativeAd.headline

        if let body = nativeAd.body {
            bodyLabel.text = body
            bodyLabel.isHidden = false
        } else {
            bodyLabel.isHidden = true
        }

        if let icon = nativeAd.icon {
            iconView.image = icon.image
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        if let cta = nativeAd.callToAction {
            ctaButton.setTitle(cta, for: .normal)
            ctaButton.isHidden = false
        } else {
            ctaButton.isHidden = true
        }

        if let rating = nativeAd.starRating {
            let full = Int(rating.doubleValue.rounded())
            starsLabel.text = String(repeating: "★", count: full) +
                               String(repeating: "☆", count: 5 - full)
            badgeRow.isHidden = false
        } else {
            starsLabel.text = ""
        }

        adView.nativeAd = nativeAd

        return adView
    }
}
// import Foundation
// import google_mobile_ads
// import GoogleMobileAds

// class NativeAdFactory: FLTNativeAdFactory {

//     func createNativeAd(
//         _ nativeAd: GADNativeAd,
//         customOptions: [AnyHashable : Any]? = nil
//     ) -> GADNativeAdView? {

//         let adView = GADNativeAdView()
//         adView.backgroundColor = .white

//         // Container
//         let container = UIStackView()
//         container.axis = .vertical
//         container.spacing = 8
//         container.translatesAutoresizingMaskIntoConstraints = false
//         adView.addSubview(container)

//         NSLayoutConstraint.activate([
//             container.topAnchor.constraint(equalTo: adView.topAnchor, constant: 10),
//             container.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -10),
//             container.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 10),
//             container.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -10)
//         ])

//         // 1. Media view (top)
//         let mediaView = GADMediaView()
//         mediaView.translatesAutoresizingMaskIntoConstraints = false
//         mediaView.heightAnchor.constraint(equalToConstant: 150).isActive = true
//         container.addArrangedSubview(mediaView)
//         adView.mediaView = mediaView

//         // 2. Icon + headline + badge/stars row
//         let topRow = UIStackView()
//         topRow.axis = .horizontal
//         topRow.spacing = 8
//         topRow.alignment = .center
//         container.addArrangedSubview(topRow)

//         let iconView = UIImageView()
//         iconView.contentMode = .scaleAspectFill
//         iconView.clipsToBounds = true
//         iconView.translatesAutoresizingMaskIntoConstraints = false
//         iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
//         iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true
//         topRow.addArrangedSubview(iconView)
//         adView.iconView = iconView

//         let textColumn = UIStackView()
//         textColumn.axis = .vertical
//         textColumn.spacing = 2
//         topRow.addArrangedSubview(textColumn)

//         let headlineLabel = UILabel()
//         headlineLabel.font = .boldSystemFont(ofSize: 13)
//         headlineLabel.textColor = .black
//         headlineLabel.numberOfLines = 1
//         textColumn.addArrangedSubview(headlineLabel)
//         adView.headlineView = headlineLabel

//         let badgeRow = UIStackView()
//         badgeRow.axis = .horizontal
//         badgeRow.spacing = 6
//         badgeRow.alignment = .center
//         textColumn.addArrangedSubview(badgeRow)

//         let adBadge = UILabel()
//         adBadge.text = "Ad"
//         adBadge.font = .systemFont(ofSize: 9)
//         adBadge.textColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1) // #4CAF50
//         adBadge.layer.borderColor = adBadge.textColor.cgColor
//         adBadge.layer.borderWidth = 1
//         adBadge.layer.cornerRadius = 2
//         adBadge.textAlignment = .center
//         adBadge.translatesAutoresizingMaskIntoConstraints = false
//         adBadge.widthAnchor.constraint(equalToConstant: 22).isActive = true
//         adBadge.heightAnchor.constraint(equalToConstant: 14).isActive = true
//         badgeRow.addArrangedSubview(adBadge)

//         let starsLabel = UILabel() // simple star text instead of RatingBar
//         starsLabel.font = .systemFont(ofSize: 11)
//         starsLabel.textColor = UIColor(red: 1, green: 0.757, blue: 0.027, alpha: 1) // #FFC107
//         badgeRow.addArrangedSubview(starsLabel)
//         // we'll fill starsLabel manually below (no native AdStarRatingView equivalent label, store ref)

//         // 3. Body text
//         let bodyLabel = UILabel()
//         bodyLabel.font = .systemFont(ofSize: 12)
//         bodyLabel.textColor = UIColor(white: 0.33, alpha: 1)
//         bodyLabel.numberOfLines = 2
//         container.addArrangedSubview(bodyLabel)
//         adView.bodyView = bodyLabel

//         // 4. CTA button
//         let ctaButton = UIButton(type: .system)
//         ctaButton.backgroundColor = UIColor(red: 0.184, green: 0.620, blue: 0.573, alpha: 1) // #2F9E92
//         ctaButton.setTitleColor(.white, for: .normal)
//         ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
//         ctaButton.layer.cornerRadius = 6
//         ctaButton.isUserInteractionEnabled = false // GADNativeAdView handles taps
//         ctaButton.translatesAutoresizingMaskIntoConstraints = false
//         ctaButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//         container.addArrangedSubview(ctaButton)
//         adView.callToActionView = ctaButton

//         // ---- Populate content ----
//         headlineLabel.text = nativeAd.headline

//         if let body = nativeAd.body {
//             bodyLabel.text = body
//             bodyLabel.isHidden = false
//         } else {
//             bodyLabel.isHidden = true
//         }

//         if let icon = nativeAd.icon {
//             iconView.image = icon.image
//             iconView.isHidden = false
//         } else {
//             iconView.isHidden = true
//         }

//         if let cta = nativeAd.callToAction {
//             ctaButton.setTitle(cta, for: .normal)
//             ctaButton.isHidden = false
//         } else {
//             ctaButton.isHidden = true
//         }

//         if let rating = nativeAd.starRating {
//             let full = Int(rating.doubleValue.rounded())
//             starsLabel.text = String(repeating: "★", count: full) +
//                                String(repeating: "☆", count: 5 - full)
//             badgeRow.isHidden = false
//         } else {
//             starsLabel.text = ""
//         }

//         adView.nativeAd = nativeAd

//         return adView
//     }
// }
