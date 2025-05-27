function deleteSelectedSymbols(fig, listbox)
    selected = listbox.Value;

    if isempty(selected)
        uialert(fig, '삭제할 항목을 선택하세요.', '경고', 'Icon', 'warning');
        return;
    end

    symbols = fig.UserData.symbols;
    symbols(ismember(symbols, selected)) = [];

    fig.UserData.symbols = symbols;
    assignin('base', 'savedSymbols', symbols);
    listbox.Items = symbols;

    if isfield(fig.UserData, 'symbolListBox') && isvalid(fig.UserData.symbolListBox)
        fig.UserData.symbolListBox.Value = {strjoin(symbols, ', ')};
    end

    uialert(fig, '선택된 Symbol이 삭제되었습니다.', '완료', 'Icon', 'info');
end
