import 'package:flutter/material.dart';

import '../../strings/oficina_strings.dart';

/// Um widget de tabela completo, reutilizável e estilizado.
///
/// Oferece funcionalidades como paginação, contador de linhas, ações customizáveis
/// e uma mensagem customizada para quando não há dados.
/// É construído para ser flexível e se adaptar a diferentes necessidades de exibição de dados.
class TableAll extends StatefulWidget {
  // --- PARÂMETROS OBRIGATÓRIOS ---

  /// A lista de widgets que compõem o cabeçalho da tabela.
  /// Cada widget representa o título de uma coluna.
  final List<Widget> headers;

  /// A lista de widgets que representam as linhas da tabela.
  /// Cada widget geralmente é um `Row` ou similar que corresponde às colunas do cabeçalho.
  final List<Widget> rows;

  /// O número máximo de linhas a serem exibidas por página.
  final int maxRows;

  // --- PARÂMETROS OPCIONAIS DE LAYOUT E ESTILO ---

  /// Altura fixa para o container da tabela. Se for nulo, a altura será intrínseca.
  final double? height;

  /// Uma lista de widgets de ação (ex: botões de 'Adicionar', 'Filtrar').
  /// Exibido no canto superior direito.
  final List<Widget>? actions;

  // --- PARÂMETROS OPCIONAIS DE COMPORTAMENTO ---

  /// Controla a visibilidade das ações. Padrão é `false`.
  final bool? showActions;

  /// Controla a visibilidade do contador de resultados. Padrão é `true`.
  final bool? showRowsCounter;

  /// Controla a visibilidade da barra de paginação. Padrão é `true`.
  final bool? showPagination;

  // --- PARÂMETROS OPCIONAIS PARA MENSAGEM DE 'VAZIO' ---

  /// Título exibido quando a lista de `rows` está vazia.
  final String? titleEmpty;

  /// Mensagem de subtítulo exibida quando a lista de `rows` está vazia.
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
  // --- VARIÁVEIS DE ESTADO DA TABELA ---

  /// O número total de páginas, calculado com base em `widget.rows.length` e `widget.maxRows`.
  int _numPages = 0;

  /// A sublista de linhas que está sendo exibida na página atual.
  List<Widget> _rowsToShow = [];

  /// O índice da página atual (baseado em zero, ou seja, 0 é a primeira página).
  int _currentPage = 0;

  // --- DEFINIÇÕES DE CORES DO TEMA DA TABELA ---
  final Color _cardColor = const Color(0xFF1E1E1E); // Fundo do Card principal
  final Color _paginationColor = const Color(0xFF121212); // Fundo de elementos menores como o contador
  final Color _dividerColor = Colors.white10; // Cor para linhas divisórias sutis
  final Color _highlightColor = Colors.blueAccent; // Cor de destaque para botões e seleção

  // --- MÉTODOS DO CICLO DE VIDA DO WIDGET ---

  @override
  void initState() {
    super.initState();
    // Inicia a tabela calculando a paginação e exibindo a primeira página.
    _updateTable();
  }

  /// Chamado sempre que o widget pai reconstrói e passa novos dados.
  /// Essencial para manter a tabela sincronizada se os dados externos mudarem.
  @override
  void didUpdateWidget(TableAll oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a lista de linhas mudou ou se a página atual se tornou inválida (ex: após uma busca),
    // reseta para a primeira página para evitar erros de índice.
    if (widget.rows.isEmpty || _currentPage * widget.maxRows >= widget.rows.length) {
      _currentPage = 0;
    }
    // Atualiza a exibição da tabela com os novos dados.
    _updateTable();
  }

  // --- MÉTODOS DE LÓGICA E CONTROLE DE ESTADO ---

  /// Recalcula o estado da tabela (número de páginas e linhas a exibir).
  /// Esta função é o coração da lógica de paginação.
  void _updateTable() {
    setState(() {
      // Calcula o número total de páginas, arredondando para cima.
      _numPages = (widget.rows.length / widget.maxRows).ceil();
      if (_numPages == 0) _numPages = 1; // Garante que haja pelo menos uma página, mesmo que vazia.

      // Define os índices de início e fim para fatiar a lista de linhas.
      final startIndex = _currentPage * widget.maxRows;
      final endIndex = startIndex + widget.maxRows;

      // Cria a sublista de linhas para a página atual, com segurança para não estourar o índice.
      _rowsToShow = widget.rows.sublist(
        startIndex,
        endIndex > widget.rows.length ? widget.rows.length : endIndex,
      );
    });
  }

  /// Pula para uma página específica.
  /// O parâmetro `page` é baseado em 1 (interface do usuário), mas é convertido para `_currentPage` (baseado em 0).
  void _jumpToPage(int page) {
    setState(() {
      _currentPage = page - 1;
      _updateTable();
    });
  }

  // Funções de atalho para navegação na paginação.
  void _goToFirstPage() => _jumpToPage(1);
  void _goToLastPage() => _jumpToPage(_numPages);

  /// Avança para a próxima página, se não estiver na última.
  void _goToNextPage() {
    if (_currentPage < _numPages - 1) _jumpToPage(_currentPage + 2);
  }

  /// Retorna para a página anterior, se não estiver na primeira.
  void _goToPreviousPage() {
    if (_currentPage > 0) _jumpToPage(_currentPage);
  }

  // --- WIDGETS DE CONSTRUÇÃO DA UI (COMPONENTES INTERNOS) ---

  /// Constrói o widget que mostra o número total de resultados.
  Widget _numMaxRows() {
    return Container(
      height: 30,
      width: 50,
      decoration: BoxDecoration(
        color: _paginationColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _dividerColor),
      ),
      child: Center(
        child: Text(
          widget.rows.length.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  /// Constrói o texto "Resultados" ao lado do contador.
  Widget _titleMaxRows() {
    return const Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text(
        OficinaStrings.resultados,
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }

  /// Constrói a área de ações, se `showActions` for verdadeiro e `actions` for fornecido.
  Widget _actions() {
    if (widget.actions != null && (widget.showActions ?? false)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.actions!,
      );
    }
    // Retorna um widget vazio e sem dimensão se não houver ações.
    return const SizedBox.shrink();
  }

  /// Constrói a barra superior que contém o contador de linhas e as ações.
  Widget _rowsCounterAndActions() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _dividerColor)),
      ),
      child: Row(
        children: [
          _numMaxRows(),
          _titleMaxRows(),
          const Spacer(), // Ocupa o espaço entre o contador e as ações.
          _actions(),
        ],
      ),
    );
  }

  /// Constrói o cabeçalho completo da tabela, incluindo opcionalmente o contador e as ações.
  Widget _header() {
    return Column(
      children: [
        // Mostra o contador de linhas por padrão, a menos que `showRowsCounter` seja `false`.
        if (widget.showRowsCounter ?? true) _rowsCounterAndActions(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            border: Border(bottom: BorderSide(color: _dividerColor, width: 2)),
          ),
          child: Row(children: widget.headers),
        ),
      ],
    );
  }

  /// Constrói o corpo da tabela onde as linhas de dados são renderizadas.
  Widget _tableBody(List<Widget> rows) {
    // `ListView.separated` é eficiente e adiciona um divisor entre cada linha.
    return ListView.separated(
      padding: const EdgeInsets.only(top: 0, bottom: 60), // Previne que o conteúdo fique sob o footer.
      itemCount: rows.length,
      separatorBuilder: (context, index) => Divider(color: _dividerColor, height: 1),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: rows[index],
        );
      },
    );
  }

  /// Constrói o rodapé da tabela, que é a barra de paginação.
  Widget _footer() {
    // Mostra a paginação por padrão, a menos que `showPagination` seja `false`.
    if ((widget.showPagination ?? true) && _numPages > 1) {
      return _pagination();
    }
    return const SizedBox.shrink();
  }

  /// Constrói um único botão de número de página para a barra de paginação.
  Widget _pageNumber({required String title, required VoidCallback? onTap, required int index}) {
    final isSelected = (index - 1 == _currentPage);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 32,
        width: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected ? _highlightColor : Colors.transparent,
          border: isSelected ? null : Border.all(color: _dividerColor),
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

  /// Constrói a barra de paginação completa com botões de navegação e números de página.
  Widget _pagination() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _dividerColor)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botões de navegação: primeira página e página anterior.
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 0 ? _goToFirstPage : null,
            color: _highlightColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage > 0 ? _goToPreviousPage : null,
            color: _highlightColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),

          // Gera os botões de número de página dinamicamente.
          ..._paginationPages(_currentPage + 1, _numPages),

          // Botões de navegação: próxima página e última página.
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage < _numPages - 1 ? _goToNextPage : null,
            color: _highlightColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < _numPages - 1 ? _goToLastPage : null,
            color: _highlightColor,
            disabledColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  /// Lógica para gerar a lista de widgets de números de página (ex: "1", "2", "...", "5").
  List<Widget> _paginationPages(int currentPage, int numPages) {
    const int maxVisibleNumbers = 5;
    List<Widget> paginationWidgets = [];

    if (numPages <= maxVisibleNumbers) {
      // Se houver poucas páginas, mostra todos os números.
      for (int i = 1; i <= numPages; i++) {
        paginationWidgets.add(_pageNumber(title: i.toString(), onTap: () => _jumpToPage(i), index: i));
      }
    } else {
      // Lógica para mostrar "..." quando há muitas páginas.
      // Exibe "..." no início se a página atual estiver avançada.
      if (currentPage > 3) paginationWidgets.add(_pageNumber(title: '...', onTap: null, index: -1));

      // Define a janela de páginas visíveis ao redor da página atual.
      int startPage = currentPage > 2 ? currentPage - 1 : 1;
      int endPage = currentPage < numPages - 1 ? currentPage + 1 : numPages;

      if (currentPage == 1) endPage = 3;
      if (currentPage == numPages) startPage = numPages - 2;

      for (int i = startPage; i <= endPage; i++) {
        paginationWidgets.add(_pageNumber(title: i.toString(), onTap: () => _jumpToPage(i), index: i));
      }

      // Exibe "..." no final se a página atual não estiver perto do fim.
      if (currentPage < numPages - 2) {
        paginationWidgets.add(_pageNumber(title: '...', onTap: null, index: -1));
      }
    }
    return paginationWidgets;
  }

  /// Constrói a mensagem a ser exibida quando a tabela está vazia.
  Widget _emptyMessage({double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            widget.titleEmpty ?? OficinaStrings.nenhumRegistroEncontrado,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (widget.messageEmpty != null) ...[
            const SizedBox(height: 8),
            Text(widget.messageEmpty!, style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 16),
          // Exibe as ações também na tela de vazio, para permitir (ex:) "Adicionar Novo".
          _actions(),
        ],
      ),
    );
  }

  // --- MÉTODO BUILD PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    // Se a lista de linhas estiver vazia, exibe a mensagem customizada.
    if (widget.rows.isEmpty) {
      return _emptyMessage(height: widget.height);
    }

    // Se houver dados, constrói a tabela completa.
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11), // Clip para arredondar o conteúdo interno
        child: Column(
          children: [
            _header(),
            // `Expanded` faz com que o corpo da tabela ocupe  o espaço vertical
            // disponível entre o cabeçalho e o rodapé.
            Expanded(
              child: _tableBody(
                // Se a paginação estiver desativada, mostra todas as linhas.
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
