package com.example.islamlearning   // ← match MainActivity's package

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactory(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {   // ← qualify with the outer class

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val adView = layoutInflater.inflate(
            R.layout.native_ad_medium_280,
            null
        ) as NativeAdView

        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        val body     = adView.findViewById<TextView>(R.id.ad_body)
        val icon     = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val media    = adView.findViewById<MediaView>(R.id.ad_media)
        val cta      = adView.findViewById<Button>(R.id.ad_call_to_action)
        val rating   = adView.findViewById<RatingBar>(R.id.ad_stars)

        headline.text      = nativeAd.headline
        adView.headlineView = headline

        if (nativeAd.body != null) {
            body.text      = nativeAd.body
            adView.bodyView = body
        } else body.visibility = View.GONE

        if (nativeAd.icon != null) {
            icon.setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView = icon
        } else icon.visibility = View.GONE

        adView.mediaView = media

        if (nativeAd.callToAction != null) {
            cta.text             = nativeAd.callToAction
            adView.callToActionView = cta
        } else cta.visibility = View.GONE

        if (nativeAd.starRating != null) {
            rating.rating         = nativeAd.starRating!!.toFloat()
            adView.starRatingView = rating
        } else rating.visibility = View.GONE

        adView.setNativeAd(nativeAd)
        return adView
    }
}