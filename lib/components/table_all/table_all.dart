import 'package:flutter/material.dart';

class TableAll extends StatefulWidget {
  /// A lista [headers] contém os cabeçalhos da tabela.
  /// A quantidade e o tamanho dos cabeçalhos devem corresponder exatamente ao número e tamanho das células
  /// em cada linha da tabela.
  final List<Widget> headers;

  /// A lista [rows] contém as linhas de dados da tabela.
  /// Cada linha deve conter uma lista de células, sendo que o número e o tamanho das células
  /// devem ser compatíveis com os cabeçalhos definidos em [headers].
  final List<Widget> rows;

  /// O parâmetro [maxRows] define o número máximo de linhas a serem exibidas por página na tabela.
  /// Esse valor é útil para implementar a paginação da tabela.
  final int maxRows;

  /// O parâmetro [height] define a altura máxima da tabela.
  /// Caso você deseje que a tabela ocupe o máximo de espaço disponível, pode envolver o widget com um `Expanded`
  /// e omitir este parâmetro.
  final double? height;

  /// A lista [actions] permite adicionar widgets adicionais ao cabeçalho da tabela, como botões, textos ou ícones.
  final List<Widget>? actions;

  /// O parâmetro [showActions] controla a exibição das ações no cabeçalho da tabela.
  /// Se estiver definido como `true`, as ações presentes em [actions] serão exibidas.
  final bool? showActions;

  /// O parâmetro [showRowsCounter] define se o contador de linhas será exibido na tabela.
  /// Se for `true`, o contador de linhas será mostrado.
  final bool? showRowsCounter;

  /// O parâmetro [showPagination] controla a exibição da paginação na tabela.
  /// Se estiver `true`, a tabela será dividida em páginas. Se for `false`, todas as linhas serão mostradas em uma única página.
  final bool? showPagination;

  /// O parâmetro [titleEmpty] é o Titulo que é mostrado quando a tabela não tem dados para serem mostrados .
  final String? titleEmpty;

  /// O parâmetro [messageEmpty] é a mensagem que é mostrada quando a tabela não tem dados para serem mostrados .
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
  // Numero de paginas da tabela (conforme o numero de dados e o numero de linhas por pagina).
  int _numPages = 0;

  // Numero de paginas da linhas mostradas por tela.
  List<Widget> _rowsToShow = [];

  // Pagina atual em que a tabela se encontra.
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Atualiza a tabela
    _updateTable();
  }

  // Altera pagina atual da tabela.
  void _jumpToPage(int page) {
    setState(() {
      _currentPage = page - 1;
      _updateTable();
    });
  }

  // Atualiza a tabela
  void _updateTable() {
    setState(() {
      // Calcula o número total de páginas que o componente pode exibir,
      // dividindo o número de linhas (widget.rows.length) pela quantidade máxima de linhas por página (widget.maxRows)
      // O .ceil() arredonda para cima, para garantir que qualquer fração de página seja contabilizada como uma página inteira.
      _numPages = (widget.rows.length / widget.maxRows).ceil();

      // Calcula o índice inicial da sublista com base na página atual (_currentPage) e no número máximo de linhas por página (widget.maxRows).
      final startIndex = _currentPage * widget.maxRows;

      // Calcula o índice final, que é o índice inicial + o número máximo de linhas.
      final endIndex = startIndex + widget.maxRows;

      // Cria uma sublista de linhas (_rowsToShow) que irá ser exibida na página atual,
      // tomando um intervalo de startIndex até endIndex. Se o endIndex ultrapassar o número total de linhas,
      // o código ajusta o endIndex para não exceder o tamanho da lista de rows.
      _rowsToShow = widget.rows.sublist(
        startIndex,
        endIndex > widget.rows.length ? widget.rows.length : endIndex,
      );
    });
  }

  // Função que mostra a primeira pagina da tabela
  void _goToFirstPage() {
    _jumpToPage(1);
  }

  // Função que mostra a ultima pagina da tabela
  void _goToLastPage() {
    _jumpToPage(_numPages);
  }

  // Função que mostra a proxima pagina da tabela
  void _goToNextPage() {
    if (_currentPage < _numPages - 1) {
      _jumpToPage(_currentPage + 2);
    }
  }

  // Função que mostra a pagina anterior da tabela
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _jumpToPage(_currentPage);
    }
  }

  void canAdvance({required void Function() onTap}) {
    if (_currentPage < _numPages - 1) onTap();
  }

  void canGoBack({required void Function() onTap}) {
    if (_currentPage > 0) onTap();
  }

  // Função que constroi o numero de linhas (registros da tabela)
  Widget _numMaxRows() {
    return Container(
      height: 30,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          widget.rows.length.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // Função que constroi o titulo do número de linhas (registros da tabela)
  Widget _titleMaxRows() {
    return Row(
      children: [
        const SizedBox(width: 8.0),
        Text(
          'Resultados encontrados',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Função que constroi os actions da tabela. (botões, texto, icones...)
  Widget _actions() {
    if (widget.actions != null && widget.showActions != null) {
      if (widget.showActions ?? false) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.actions!,
        );
      }
    }

    return const SizedBox.shrink();
  }

  // Função que junta o numero de linhas, titulo e actions da tabela.
  Widget _rowsCounterAndActions() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          _numMaxRows(),
          _titleMaxRows(),
          const Spacer(),
          _actions(),
        ],
      ),
    );
  }

  // Cria header da tabela. juntando numero de linhas, actions e headers passados no parametro da tabela.
  Widget _header() {
    return Column(
      children: [
        if (widget.showRowsCounter ?? true) _rowsCounterAndActions(),
        Row(children: widget.headers),
      ],
    );
  }

  // Cria header da tabela. juntando numero de linhas, actions e headers passados no parametro da tabela.
  Widget _tableBody(List<Widget> rows) {
    // Padding ajustado para o GridTile não sobrepor conteúdo
    return Padding(
      padding: const EdgeInsets.only(top: 90, bottom: 45),
      child: ListView(children: rows),
    );
  }

  // Cria footer com a paginação da tabela.
  Widget _footer() {
    // Só mostra paginação caso showPaginacao seja true
    if (widget.showPagination ?? true) {
      return _pagination();
    }

    return const SizedBox.shrink();
  }

  // Junta todos os componentes da tabela (header, body e footer)
  Widget _table() {
    List<Widget> rows = widget.rows;

    if (widget.showPagination ?? true) {
      rows = _rowsToShow;
    }

    return GridTile(
      header: _header(),
      footer: _footer(),
      child: _tableBody(rows),
    );
  }

  // Mensagem caso a tabela esteja vazia
  Widget _emptyMessage({double? height}) {
    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.titleEmpty ?? 'Sem dados',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.messageEmpty != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.messageEmpty!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            _actions(),
          ],
        ),
      ),
    );
  }

  // Define cores dos botoes de voltar da tabela
  Color _goBackButtonColor() {
    if (_currentPage > 0) {
      return Theme.of(context).primaryColor;
    }

    return Colors.grey;
  }

  // Define cores dos avancar de voltar da tabela
  Color _advanceButtonColor() {
    if (_currentPage < _numPages - 1) {
      return Theme.of(context).primaryColor;
    }

    return Colors.grey;
  }

  List<Widget> _paginationPages(int currentPage, int numPages) {
    // Define a constante para o número máximo de páginas visíveis na navegação.
    const int maxVisibleNumbers = 5;

    // Cria uma lista de widgets que será retornada, representando os itens de navegação de página.
    List<Widget> paginationWidgets = [];

    // Se o número total de páginas for menor ou igual ao número máximo de páginas visíveis,
    // exibe todas as páginas como botões.
    if (numPages <= maxVisibleNumbers) {
      for (int i = 1; i <= numPages; i++) {
        paginationWidgets.add(
          _pageNumber(
            title: i.toString(), // Exibe o número da página.
            onTap: () => _jumpToPage(i), // Ao clicar, chama a função para pular para a página correspondente.
            index: i, // O índice da página.
          ),
        );
      }
    } else {
      // Se o número de páginas for maior do que o limite máximo visível (maxVisibleNumbers),
      // adiciona o botão "..." para indicar páginas extras, caso o currentPage seja maior que 3.
      if (currentPage > 3) paginationWidgets.add(_more());

      // Define o intervalo de páginas a serem exibidas: se a página atual (currentPage) for maior que 3,
      // começa a exibir duas páginas antes dela, senão começa pela primeira página.
      int startPage = currentPage > 3 ? currentPage - 2 : 1;

      // Define o final do intervalo, garantindo que o índice não ultrapasse o número total de páginas.
      int endPage = currentPage + 2 > numPages ? numPages : currentPage + 2;

      // Adiciona as páginas dentro do intervalo calculado à lista de widgets.
      for (int i = startPage; i <= endPage; i++) {
        paginationWidgets.add(
          _pageNumber(
            title: i.toString(), // Exibe o número da página.
            onTap: () => _jumpToPage(i), // Ao clicar, chama a função para pular para a página correspondente.
            index: i, // O índice da página.
          ),
        );
      }

      // Se a página atual for menor que a última página visível com base no intervalo,
      // adiciona o botão "..." para indicar mais páginas.
      if (currentPage < numPages - 2) {
        paginationWidgets.add(_more());
      }
    }

    // Retorna a lista de widgets de navegação de página.
    return paginationWidgets;
  }

  // Monta o componentes do numero da pagina da paginação.
  Widget _pageNumber({
    required String title,
    required void Function()? onTap,
    required int index,
  }) {
    final isSelected = (index - 1 == _currentPage);
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 30,
        width: 30,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected ? primaryColor : Colors.grey[400],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  // Monta o componentes do numero da pagina da paginação de mais (...).
  Widget _more() {
    return _pageNumber(
      title: '...',
      onTap: () => {},
      index: -1,
    );
  }

  // Monta a paginação da tabela
  Widget _pagination() {
    return Container(
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.first_page),
            onPressed: () => canGoBack(onTap: () => _goToFirstPage()),
            color: _goBackButtonColor(),
            tooltip: 'Primeira página',
          ),
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.navigate_before),
            onPressed: () => canGoBack(onTap: () => _goToPreviousPage()),
            color: _goBackButtonColor(),
            tooltip: 'Página anterior',
          ),
          ..._paginationPages(_currentPage + 1, _numPages),
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.navigate_next),
            onPressed: () => canAdvance(onTap: () => _goToNextPage()),
            color: _advanceButtonColor(),
            tooltip: 'Proxima página',
          ),
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.last_page),
            onPressed: () => canAdvance(onTap: () => _goToLastPage()),
            color: _advanceButtonColor(),
            tooltip: 'Ultima página',
          ),
        ],
      ),
    );
  }

  // Junta todos os componentes da tabela e coloca um card ao fundo.
  Widget _body() {
    return SizedBox(
      height: widget.height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _table(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Caso a tabela esteja vazia, mostra mensagem
    if (widget.rows.isEmpty) {
      if (widget.height != null) {
        return _emptyMessage(height: widget.height);
      }
      return Expanded(child: _emptyMessage());
    }

    // Mostra a tabela.
    if (widget.height != null) {
      return _body();
    }

    return Expanded(child: _body());
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
}