import 'package:flutter/widgets.dart';

import 'rendering.dart';

class SliverInteractiveViewer extends StatefulWidget {
  const SliverInteractiveViewer({
    super.key,
    required this.child,
    this.maxScale = 2.0,
    this.minScale = 1.0,
  });

  final Widget child;
  final double maxScale;
  final double minScale;

  @override
  State<SliverInteractiveViewer> createState() =>
      _SliverInteractiveViewerState();
}

class _SliverInteractiveViewerState extends State<SliverInteractiveViewer> {
  @override
  Widget build(BuildContext context) {
    return SliverInteractiveViewerRenderObjectWidget(
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      child: widget.child,
    );
  }
}

class SliverInteractiveViewerRenderObjectWidget
    extends SingleChildRenderObjectWidget {
  const SliverInteractiveViewerRenderObjectWidget({
    super.key,
    required this.maxScale,
    required this.minScale,
    super.child,
  });

  final double maxScale;
  final double minScale;

  @override
  void updateRenderObject(BuildContext context,
      covariant RenderSliverInteractiveViewer renderObject) {
    renderObject
      ..maxScale = maxScale
      ..minScale = minScale;
  }

  @override
  RenderSliverInteractiveViewer createRenderObject(BuildContext context) =>
      RenderSliverInteractiveViewer(maxScale: maxScale, minScale: minScale);
}
