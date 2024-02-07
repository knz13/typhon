



import 'package:flutter/material.dart';

class TreeViewer<T> extends StatefulWidget {
  final List<T> items;
  final double itemHeight;
  final Widget Function(T) itemBuilder;
  final List<T> Function(T) getSubItems;

  const TreeViewer({
    super.key,
    required this.items,
    required this.itemHeight,
    required this.itemBuilder,
    required this.getSubItems
  });

  @override
  _TreeViewerState<T> createState() => _TreeViewerState<T>();
}

class _TreeViewerState<T> extends State<TreeViewer<T>> {
  final List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _isExpandedList.addAll(List<bool>.filled(widget.items.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];
        return Column(
          children: [
            SizedBox(
              height: widget.itemHeight,
              child: Expanded(
                        child: widget.itemBuilder(item),
                ),
            ),
            SizedBox(
              height: widget.itemHeight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpandedList[index] = !_isExpandedList[index];
                  });
                },
                child: Icon(
                  _isExpandedList[index]
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                ),
              ),
            ),
            _isExpandedList[index]
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TreeViewer<T>(
                      items: widget.getSubItems(item),
                      itemHeight: widget.itemHeight,
                      itemBuilder: widget.itemBuilder,
                      getSubItems: widget.getSubItems,
                    ),
                  )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}