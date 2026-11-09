import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";

const _sidePadding = 16.0;

const _imageAspectRatio = 2.0;

/// Autoplay is off when the OS "reduce motion" setting is on.
({
  CarouselSliderController controller,
  int current,
  double sidePadding,
  CarouselOptions options,
})
useHomeBannerCarousel() {
  // No dispose(): CarouselSliderController holds no resources.
  final controller = useMemoized(CarouselSliderController.new);

  final current = useState(0);

  final context = useContext();

  final reduceMotion = MediaQuery.disableAnimationsOf(context);

  // aspectRatio covers the whole slide incl. the 16px side padding, so derive it
  // from the screen width to keep the image itself at exactly 2:1 (no cropping).
  final width = MediaQuery.sizeOf(context).width;

  final slideAspectRatio =
      width / ((width - _sidePadding * 2) / _imageAspectRatio);

  return (
    controller: controller,
    current: current.value,
    sidePadding: _sidePadding,
    options: CarouselOptions(
      aspectRatio: slideAspectRatio,
      viewportFraction: 1,
      autoPlay: !reduceMotion,
      autoPlayInterval: const Duration(seconds: 4),
      autoPlayCurve: Curves.easeOutCubic,
      onPageChanged: (i, _) => current.value = i,
    ),
  );
}
