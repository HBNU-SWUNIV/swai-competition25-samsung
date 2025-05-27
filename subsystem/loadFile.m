function loadFile(fig)
    [file, path] = uigetfile('*.mat', '불러올 파일 선택');
    if isequal(file, 0) || isequal(path, 0)
        return;
    end

    loaded = load(fullfile(path, file), 'savedData');
    if ~isfield(loaded, 'savedData')
        uialert(fig, '선택한 파일에 저장된 데이터가 없습니다.', '오류', 'Icon', 'error');
        return;
    end

    savedData = loaded.savedData;

    % 🔹 API 키 복원
    if isfield(savedData, 'apiData')
        assignin('base', 'savedData', savedData.apiData);
    end

    % 🔹 심볼 복원
    if isfield(savedData, 'symbols')
        assignin('base', 'savedSymbols', savedData.symbols);
        fig.UserData.symbols = savedData.symbols;
        if isfield(fig.UserData, 'symbolList') && isgraphics(fig.UserData.symbolList)
            fig.UserData.symbolList.Items = savedData.symbols;
        end
    end

    % 🔹 포트폴리오 Pie Chart 복원
    % if isfield(savedData, 'portfolioData') && ~isempty(savedData.portfolioData)
    %     pieData = savedData.portfolioData;
    %     if isfield(fig.UserData, 'pieAxes') && isgraphics(fig.UserData.pieAxes)
    %         pie(fig.UserData.pieAxes, pieData.assetPercentage);
    %         legend(fig.UserData.pieAxes, pieData.legendStrings, 'Location', 'eastoutside');
    %         title(fig.UserData.pieAxes, ['Portfolio Allocation by Stock (', pieData.date, ')']);
    %         fig.UserData.latestPortfolioData = pieData;
    %     end
    % end

    uialert(fig, '파일이 성공적으로 불러와졌습니다.', '불러오기 완료', 'Icon', 'success');
end
