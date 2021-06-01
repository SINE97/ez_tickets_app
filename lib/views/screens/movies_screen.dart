import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//Helper
import '../../helper/utils/constants.dart';

//Providers
import '../../providers/movies_provider.dart';
import '../../providers/all_providers.dart';

//Services
import '../../services/networking/network_exception.dart';

//Widgets
import '../widgets/common/custom_error_widget.dart';
import '../widgets/movies/movie_backdrop_view.dart';
import '../widgets/movies/movie_carousel.dart';
import '../widgets/movies/movie_icons_row.dart';

//Skeletons
import '../skeletons/movies_skeleton_loader.dart';

class MoviesScreen extends HookWidget {
  const MoviesScreen();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final movies = useProvider(moviesFuture(null));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 550),
        switchOutCurve: Curves.easeInBack,
        child: movies.when(
          data: (movies) {
            final backgroundImageController = usePageController(
              initialPage: movies.length ~/ 2,
            );
            return SizedBox.expand(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  //page controller bg
                  Positioned.fill(
                    child: MovieBackdropView(
                      backgroundImageController: backgroundImageController,
                      movies: movies,
                    ),
                  ),

                  //Top black overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 110,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: Constants.blackOverlayGradient,
                      ),
                    ),
                  ),

                  //White gradient
                  Positioned.fill(
                    top: screenHeight * 0.40,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: Constants.movieCarouselGradient,
                      ),
                    ),
                  ),

                  //Movies Carousel
                  Positioned(
                    bottom: -50,
                    top: screenHeight * 0.27,
                    child: MoviesCarousel(
                      backgroundImageController: backgroundImageController,
                      movies: movies,
                    ),
                  ),

                  //Icons row
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: MoviesIconsRow(),
                  )
                ],
              ),
            );
          },
          loading: () => const MoviesSkeletonLoader(),
          error: (error, st) {
            if (error is NetworkException) {
              return CustomErrorWidget.dark(
                error: error,
                retryCallback: () {
                  context.refresh(moviesFuture(null));
                },
                height: screenHeight * 0.5,
              );
            }
            context.read(authProvider.notifier).logout();
            context.router.popUntilRoot();
            debugPrint(error.toString());
            debugPrint(st.toString());
          },
        ),
      ),
    );
  }
}
