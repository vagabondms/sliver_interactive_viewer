import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

const double _kTransformDouble = 0.5;

class RenderSliverInteractiveViewer extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver> {
  RenderSliverInteractiveViewer({
    required this.maxScale,
    required this.minScale,
    RenderSliver? child,
  }) {
    this.child = child;

    _scaleGestureRecognizer = ScaleGestureRecognizer()
      ..onStart = (ScaleStartDetails details) {
        _initialPoint = details.focalPoint;
      }
      ..onUpdate = (ScaleUpdateDetails details) {
        final double _scale = 1 + ((details.scale - 1) * _kTransformDouble);
        scale = _scale.clamp(minScale, maxScale);
        if (_initialPoint != null) {
          delta = details.focalPoint - _initialPoint!;
        }
      }
      ..onEnd = (ScaleEndDetails details) {
        scale = 1;
        _initialPoint = null;
        delta = null;
      };
  }
  ScaleGestureRecognizer? _scaleGestureRecognizer;

  double maxScale;
  double minScale;

  Offset? _initialPoint;
  Offset? _delta;
  Offset? get delta => _delta;
  set delta(Offset? delta) {
    if (delta != null && delta != _delta) {
      _delta = delta;
      markNeedsLayout();
    } else {
      _delta = delta;
    }
  }

  double _scale = 1;
  double get scale => _scale;
  set scale(double value) {
    if (value != _scale) {
      _scale = value;
      markNeedsLayout();
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    final SliverPhysicalParentData childParentData =
        child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void dispose() {
    _scaleGestureRecognizer?.dispose();
    super.dispose();
  }

  @override
  void handleEvent(PointerEvent event, covariant SliverHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerDownEvent) {
      _scaleGestureRecognizer!.addPointer(event);
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  bool hitTestSelf({
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) =>
      true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final Rect childSize = context.estimatedBounds;

      final Matrix4 matrix = Matrix4.identity()
        ..translate(childSize.width / 2 + (delta?.dx ?? 0),
            childSize.height / 2 + (delta?.dy ?? 0))
        ..scale(scale, scale)
        ..translate(-childSize.width / 2, -childSize.height / 2);

      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & child!.paintBounds.size,
        (PaintingContext clippedContext, Offset clippedOffset) {
          clippedContext.pushTransform(needsCompositing, offset, matrix, (
            PaintingContext transformedContext,
            Offset transformOffset,
          ) {
            transformedContext.paintChild(child!, clippedOffset);
          });
        },
      );
    }
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints, parentUsesSize: true);
    final SliverGeometry childLayoutGeometry = child!.geometry!;

    final double paintExtent = math.min(
      math.max(
        childLayoutGeometry.paintExtent,
        childLayoutGeometry.layoutExtent,
      ),
      constraints.remainingPaintExtent,
    );

    geometry = SliverGeometry(
      paintOrigin: childLayoutGeometry.paintOrigin,
      scrollExtent: childLayoutGeometry.scrollExtent,
      paintExtent: paintExtent,
      layoutExtent: math.min(childLayoutGeometry.layoutExtent, paintExtent),
      cacheExtent: math.min(
        childLayoutGeometry.cacheExtent,
        constraints.remainingCacheExtent,
      ),
      maxPaintExtent: childLayoutGeometry.maxPaintExtent,
      hitTestExtent: math.max(
        childLayoutGeometry.paintExtent,
        childLayoutGeometry.hitTestExtent,
      ),
      hasVisualOverflow: false,
    );
  }
}
