function searchStock(fig)
    % ✅ Workspace에서 저장된 API 키 불러오기
    if evalin('base', 'exist(''savedData'', ''var'')')
        savedData = evalin('base', 'savedData');  
        if isfield(savedData, 'text')
            apiKey = savedData.text;
        else
            uialert(fig, 'API 키가 저장되지 않았습니다. 먼저 API를 입력하세요.', '오류', 'Icon', 'error');
            return;
        end
    else
        uialert(fig, 'API 키가 저장되지 않았습니다. 먼저 API를 입력하세요.', '오류', 'Icon', 'error');
        return;
    end

    % 🔹 사용자 입력 요청 (UI 창에서 입력)
    prompt = {'검색할 자산(회사명,금융상품)을 입력하세요:'};
    dlgtitle = '종목 탐색';
    dims = [1 50];
    query = inputdlg(prompt, dlgtitle, dims);

    % 🔹 사용자가 취소한 경우
    if isempty(query)
        return;
    end
    query = query{1};

    % 🔹 API 요청 URL 생성
    url = ['https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=' query '&apikey=' apiKey];

    try
        % 🔹 API 응답 가져오기
        response = webread(url);

        % 🔹 응답이 비어 있는지 확인
        if isempty(response) || ~isfield(response, 'bestMatches')
            uialert(fig, '검색 결과가 없습니다. API 키 또는 요청을 확인하세요.', '오류', 'Icon', 'warning');
            return;
        end

        results = response.bestMatches;
        numResults = numel(results);

        % 🔹 검색 결과가 없는 경우
        if numResults == 0
            uialert(fig, '검색 결과가 없습니다.', '알림', 'Icon', 'warning');
            return;
        end

        % 🔹 검색 결과 표시 (UI 테이블 생성)
        data = cell(numResults, 5);
        for i = 1:numResults
            symbolField = matlab.lang.makeValidName('1. symbol');
            nameField = matlab.lang.makeValidName('2. name');
            typeField = matlab.lang.makeValidName('3. type');
            regionField = matlab.lang.makeValidName('4. region');
            currencyField = matlab.lang.makeValidName('8. currency');

            data{i, 1} = results(i).(symbolField);
            data{i, 2} = results(i).(nameField);
            data{i, 3} = results(i).(typeField);
            data{i, 4} = results(i).(regionField);
            data{i, 5} = results(i).(currencyField);
        end

        % 🔹 UI 테이블 생성하여 결과 표시
        resultFig = uifigure('Name', '검색 결과', 'Position', [600, 300, 600, 400]);
        uitable(resultFig, 'Data', data, ...
            'ColumnName', {'Symbol', 'Company Name', 'Type', 'Region', 'Currency'}, ...
            'Position', [25, 50, 550, 300]);

    catch ME
        uialert(fig, ['API 요청 중 오류 발생: ' ME.message], '오류', 'Icon', 'error');
    end
end
