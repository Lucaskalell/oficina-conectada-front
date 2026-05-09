import 'package:flutter/material.dart';
import 'package:oficina_conectada_front/constants/colors.dart';
import 'package:oficina_conectada_front/constants/oficina_strings.dart';

class TableAll extends StatefulWidget {
  final List<Widget> headers;
  final List<Widget> rows;
  final int maxRows;
  final double? height;
  final List<Widget>? actions;
  final bool? showActions;
  final bool? showRowsCounter;
  final bool? showPagination;
  final String? titleEmpty;
  final String? messageEmpty;

  const TableAll({
    required this.headers,
    required this.rows,
    required this.maxRows,
    super.key,
    this.height,
    this.actions,
    this.showActions,
    this.showRowsCounter,
    this.showPagination,
    this.titleEmpty,
    this.messageEmpty,
  });

  @override
  State<TableAll> createState() => _TableAllState();
}

class _TableAllState extends State<TableAll> {
  int _numPages = 0;
  List<Widget> _rowsToShow = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _updateTable();
  }

  @override
  void didUpdateWidget(TableAll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rows.isEmpty ||
        _currentPage * widget.maxRows >= widget.rows.length) {
      _currentPage = 0;
    }
    _updateTable();
  }

  void _updateTable() {
    setState(() {
      _numPages = (widget.rows.length / widget.maxRows).ceil();
      if (_numPages == 0) _numPages = 1;

      final startIndex = _currentPage * widget.maxRows;
      final endIndex = startIndex + widget.maxRows;

      _rowsToShow = widget.rows.sublist(
        startIndex,
        endIndex > widget.rows.length ? widget.rows.length : endIndex,
      );
    });
  }

  void _jumpToPage(int page) {
    setState(() {
      _currentPage = page - 1;
      _updateTable();
    });
  }

  void _goToFirstPage() => _jumpToPage(1);
  void _goToLastPage() => _jumpToPage(_numPages);

  void _goToNextPage() {
    if (_currentPage < _numPages - 1) _jumpToPage(_currentPage + 2);
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) _jumpToPage(_currentPage);
  }

  Widget _numMaxRows() {
    return Container(
      height: 30,
      width: 50,
      decoration: BoxDecoration(
        color: ColorsApp.bgDark,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Center(
        child: Text(
          widget.rows.length.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _titleMaxRows() {
    return const Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text(
        OficinaStrings.resultados,
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }

  Widget _actions() {
    if (widget.actions != null && (widget.showActions ?? false)) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.actions!);
    }
    return const SizedBox.shrink();
  }

  Widget _rowsCounterAndActions() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorsApp.border)),
      ),
      child: Row(
        children: [_numMaxRows(), _titleMaxRows(), const Spacer(), _actions()],
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        if (widget.showRowsCounter ?? true) _rowsCounterAndActions(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: ColorsApp.cardDark,
            border: Border(bottom: BorderSide(color: ColorsApp.border, width: 2)),
          ),
          child: Row(children: widget.headers),
        ),
      ],
    );
  }

  Widget _tableBody(List<Widget> rows) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 0, bottom: 60),
      itemCount: rows.length,
      separatorBuilder:
          (context, index) => Divider(color: ColorsApp.border, height: 1),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: rows[index],
        );
      },
    );
  }

  Widget _footer() {
    if ((widget.showPagination ?? true) && _numPages > 1) {
      return _pagination();
    }
    return const SizedBox.shrink();
  }

  Widget _pageNumber({
    required String title,
    required VoidCallback? onTap,
    required int index,
  }) {
    final isSelected = (index - 1 == _currentPage);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        width: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected ? ColorsApp.primaryColor : Colors.transparent,
          border: isSelected ? null : Border.all(color: ColorsApp.border),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pagination() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        border: Border(top: BorderSide(color: ColorsApp.border)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 0 ? _goToFirstPage : null,
            color: ColorsApp.primaryColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage > 0 ? _goToPreviousPage : null,
            color: ColorsApp.primaryColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
          ..._paginationPages(_currentPage + 1, _numPages),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage < _numPages - 1 ? _goToNextPage : null,
            color: ColorsApp.primaryColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < _numPages - 1 ? _goToLastPage : null,
            color: ColorsApp.primaryColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  List<Widget> _paginationPages(int currentPage, int numPages) {
    const int maxVisibleNumbers = 5;
    List<Widget> paginationWidgets = [];

    if (numPages <= maxVisibleNumbers) {
      for (int i = 1; i <= numPages; i++) {
        paginationWidgets.add(
          _pageNumber(title: i.toString(), onTap: () => _jumpToPage(i), index: i),
        );
      }
    } else {
      if (currentPage > 3) {
        paginationWidgets.add(_pageNumber(title: '...', onTap: null, index: -1));
      }

      int startPage = currentPage > 2 ? currentPage - 1 : 1;
      int endPage = currentPage < numPages - 1 ? currentPage + 1 : numPages;

      if (currentPage == 1) endPage = 3;
      if (currentPage == numPages) startPage = numPages - 2;

      for (int i = startPage; i <= endPage; i++) {
        paginationWidgets.add(
          _pageNumber(title: i.toString(), onTap: () => _jumpToPage(i), index: i),
        );
      }

      if (currentPage < numPages - 2) {
        paginationWidgets.add(_pageNumber(title: '...', onTap: null, index: -1));
      }
    }
    return paginationWidgets;
  }

  Widget _emptyMessage({double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            widget.titleEmpty ?? OficinaStrings.nenhumRegistroEncontrado,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (widget.messageEmpty != null) ...[
            const SizedBox(height: 8),
            Text(widget.messageEmpty!, style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 16),
          _actions(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return _emptyMessage(height: widget.height);
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: ColorsApp.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _tableBody(
                (widget.showPagination ?? true) ? _rowsToShow : widget.rows,
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }
}
