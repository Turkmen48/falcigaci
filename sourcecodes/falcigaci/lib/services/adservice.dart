import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'databaseservice.dart';

class AdService {
  final String rewardedAdTestId = "ca-app-pub-3940256099942544/5224354917";
  final String rewardedAdRealId = "ca-app-pub-6626439751293050/8638777730";
  final String bannerAdRealId = "ca-app-pub-6626439751293050/2374382598";
  final String bannerAdTestId = "ca-app-pub-3940256099942544/6300978111";

  showRewardedAd({required String uid, required int count}) {
    RewardedAd.load(
        adUnitId: rewardedAdRealId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) =>
                  print('$ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (RewardedAd ad) async {
                print('$ad onAdDismissedFullScreenContent.');
                print('REKLAM KAPATILDI.');
                DatabaseService().addFalToFirestore(docId: uid, count: count);

                ad.dispose();
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                ad.dispose();
              },
              onAdImpression: (RewardedAd ad) =>
                  print('$ad impression occurred.'),
            );
            ad.show(onUserEarnedReward:
                (AdWithoutView adWithoutView, RewardItem rewardItem) async {
              print("$adWithoutView onUserEarnedReward: $rewardItem");
              print("user earned reward");
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            DatabaseService().addFalToFirestore(docId: uid, count: count);
          },
        ));
  }

  showBannerAd() {
    BannerAd myBanner = BannerAd(
      adUnitId: bannerAdRealId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    );
    myBanner.load();
    return myBanner;
  }
}
