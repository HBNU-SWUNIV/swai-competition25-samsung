function saveFile(fig)
    % 저장할 데이터 구성
    savedData = struct();

    % API 키 (base workspace에서 가져옴)
    if evalin('base', 'exist(''savedData'', ''var'')')
        savedData.apiData = evalin('base', 'savedData');
    else
        savedData.apiData = [];
    end

    % 저장된 Symbols (base workspace에서 가져옴)
    if evalin('base', 'exist(''savedSymbols'', ''var'')')
        savedData.symbols = evalin('base', 'savedSymbols');
    else
        savedData.symbols = {};
    end

    % 자산 비율 Pie Chart 데이터 저장 (fig.UserData에서 가져옴)
    if isfield(fig.UserData, 'latestPortfolioData')
        savedData.portfolioData = fig.UserData.latestPortfolioData;
    else
        savedData.portfolioData = [];
    end

    % 저장할 파일명 입력받기
    [file,path] = uiputfile('*.mat', '파일 저장하기');
    if isequal(file,0) || isequal(path,0)
        return;
    end

    % 실제 저장 수행
    save(fullfile(path, file), 'savedData');
    uialert(fig, '파일이 성공적으로 저장되었습니다.', '저장 완료', 'Icon', 'success');
end
