import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_interactive_viewer/src/rendering.dart';
import 'package:sliver_interactive_viewer/src/widget.dart';

void main() {
  group('SliverInteractiveViewer', () {
    const groupKey = ValueKey('group');

    Future<void> setUpSliverInteractiveViewer(WidgetTester tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverInteractiveViewer(
              key: groupKey,
              child: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    height: 100,
                    color: Colors.red,
                  ),
                  Container(
                    height: 100,
                    color: Colors.green,
                  ),
                  Container(
                    height: 100,
                    color: Colors.blue,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ));
    }

    testWidgets('MyWidget has a title and message', (tester) async {
      await setUpSliverInteractiveViewer(tester);

      // final sliverInteractiveViewer = tester.get(find.byKey(groupKey));
      final sliverInteractiveViewer = tester.renderObject(find.byKey(groupKey));

      expect(sliverInteractiveViewer, isNotNull);
      expect(sliverInteractiveViewer, isA<RenderSliverInteractiveViewer>());
    });
  });
}
