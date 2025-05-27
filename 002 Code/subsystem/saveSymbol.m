function saveSymbol(fig, symbolInput)
    % 입력된 Symbol 가져오기
    newSymbol = strtrim(symbolInput.Value);

    % 빈 입력값 체크
    if isempty(newSymbol)
        uialert(fig, 'Symbol을 입력하세요!', '오류', 'Icon', 'warning');
        return;
    end

    % ✅ UserData.symbols 없으면 초기화
    if ~isfield(fig.UserData, 'symbols') || isempty(fig.UserData.symbols)
        fig.UserData.symbols = {};
    end

    symbols = fig.UserData.symbols;

    % 중복이 아니라면 추가
    if ~ismember(newSymbol, symbols)
        symbols{end+1} = newSymbol;
        fig.UserData.symbols = symbols;

       

        % ✅ Workspace에 저장
        assignin('base', 'savedSymbols', symbols);

        % ✅ symbolList (리스트박스) 업데이트만
        if isfield(fig.UserData, 'symbolList') && isvalid(fig.UserData.symbolList)
            drawnow;  % 렌더링 강제
            fig.UserData.symbolList.Items = symbols;
        end

        % 알림창
        uialert(fig, ['Symbol ' newSymbol '이(가) 저장되었습니다!'], '완료', 'Icon', 'info');
    else
        uialert(fig, ['Symbol ' newSymbol '은 이미 저장되었습니다!'], '알림', 'Icon', 'warning');
    end

end
