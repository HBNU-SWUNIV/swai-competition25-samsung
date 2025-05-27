function showPortfolioPieChart(fig)%혼합이 안됨

    selection = questdlg('종목 데이터를 어떤 방식으로 입력하시겠습니까?', ...
                         '입력 방식 선택', ...
                         '저장된 심볼 사용', '직접 입력하기', '저장+직접 혼합', '저장된 심볼 사용');

    if isempty(selection)
        return;
    end

    % API Key 가져오기 (기존 코드 유지)
    if evalin('base', 'exist(''savedData'', ''var'')')
        savedData = evalin('base', 'savedData');
        if isfield(savedData, 'text')
            apiKey = savedData.text;
        else
            uialert(fig, 'API 키가 저장되지 않았습니다.', '오류', 'Icon', 'error');
            return;
        end
    else
        uialert(fig, 'API 키가 저장되지 않았습니다.', '오류', 'Icon', 'error');
        return;
    end

    validSymbols = {};
    validQuantities = [];
    validPrices = [];

    switch selection
        case '저장된 심볼 사용'
            if evalin('base', 'exist(''savedSymbols'', ''var'')')
                symbols = evalin('base', 'savedSymbols');
                if isempty(symbols)
                    uialert(fig, '저장된 Symbol이 없습니다.', '오류', 'Icon', 'error');
                    return;
                end
            else
                uialert(fig, '저장된 Symbol이 없습니다.', '오류', 'Icon', 'error');
                return;
            end

            prompt = strcat(symbols, '의 보유 수량을 입력하세요:');
            defaultQty = repmat({'0'}, size(symbols));
            answer = inputdlg(prompt, '보유 수량 입력', [1 50], defaultQty);

            if isempty(answer)
                return;
            end

           quantity = str2double(answer);
    if any(isnan(quantity))
        uialert(fig, '모든 수량을 올바르게 입력하세요.', '입력 오류', 'Icon', 'error');
        return;
    end

            for s = 1:length(symbols)
                url = ['https://www.alphavantage.co/query?function=TIME_SERIES_DAILY' ...
       '&symbol=' symbols{s} '&apikey=' apiKey];


                 try
            data = webread(url);

        if isfield(data, 'Time Series (Daily)')
            dailyData = data.('Time Series (Daily)');
        elseif isfield(data, 'TimeSeries_Daily_')
            dailyData = data.('TimeSeries_Daily_');
        elseif isfield(data, 'Error Message')
            warning('%s API 에러: %s', symbols{s}, data.('Error Message'));
            continue;
        elseif isfield(data, 'Note')
            uialert(fig, 'API 호출 제한이 초과되었습니다. 잠시 후 다시 시도하세요.', 'API 오류', 'Icon', 'error');
            return;
        else
            warning('%s 알 수 없는 API 응답.', symbols{s});
            continue;
        end

        dates = fieldnames(dailyData);
        if isempty(dates)
            warning('%s 날짜 데이터 없음.', symbols{s});
            continue;
        end

        latestDate = dates{1};
        entry = dailyData.(latestDate);

        if isfield(entry, '4. close')
            price = str2double(entry.('4. close'));
        elseif isfield(entry, 'x4_Close')
            price = str2double(entry.('x4_Close'));
        else
            warning('%s 종가 필드 없음.', symbols{s});
            continue;
        end

        if ~isnan(price)
            validSymbols{end+1} = symbols{s};
            validPrices(end+1) = price;
            validQuantities(end+1) = quantity(s);
        end

    catch ME
        warning('%s 데이터 가져오기 실패 (%s)', symbols{s}, ME.message);
        continue;
    end
            end

        case '직접 입력하기'
            prompt = {'종목 이름 (쉼표 구분):', '수량 (쉼표 구분):', '가격 (쉼표 구분):'};
            answer = inputdlg(prompt, '직접 종목 입력', [1 60], {'AAPL,MSFT','10,20','150,300'});

            if isempty(answer)
                return;
            end

            validSymbols = strtrim(strsplit(answer{1}, ','));
            validQuantities = str2double(strsplit(answer{2}, ','));
            validPrices = str2double(strsplit(answer{3}, ','));

      case '저장+직접 혼합'
    % 저장된 심볼 불러오기
    if evalin('base', 'exist(''savedSymbols'', ''var'')')
        symbols = evalin('base', 'savedSymbols');
        if isempty(symbols)
            symbols = {};
        end
    else
        symbols = {};
    end

    [indx, tf] = listdlg('PromptString', '사용할 저장된 심볼을 선택하세요:', ...
                         'ListString', symbols, 'SelectionMode','multiple');
    storedSymbols = symbols(indx);

    storedQuantities = [];
    storedPrices = [];
    validStoredSymbols = {};

    if tf && ~isempty(storedSymbols)
        prompt = strcat(storedSymbols, '의 보유 수량 입력:');
        answer = inputdlg(prompt, '저장된 심볼 수량 입력', [1 50], repmat({'0'}, size(storedSymbols)));
        if isempty(answer), return; end

        quantity = str2double(answer);
        if any(isnan(quantity))
            uialert(fig, '수량 입력 오류.', '오류', 'Icon', 'error');
            return;
        end

        for s = 1:length(storedSymbols)
            url = ['https://www.alphavantage.co/query?function=TIME_SERIES_DAILY' ...
                   '&symbol=' storedSymbols{s} '&apikey=' apiKey];
            try
                data = webread(url);

                % 🔹 저장된 심볼 사용과 동일한 방식의 예외처리 추가
                if isfield(data, 'Time Series (Daily)')
                    dailyData = data.('Time Series (Daily)');
                elseif isfield(data, 'TimeSeries_Daily_')
                    dailyData = data.('TimeSeries_Daily_');
                elseif isfield(data, 'Error Message')
                    warning('%s API 에러: %s', storedSymbols{s}, data.('Error Message'));
                    continue;
                elseif isfield(data, 'Note')
                    uialert(fig, 'API 호출 제한이 초과되었습니다. 잠시 후 다시 시도하세요.', 'API 오류', 'Icon', 'error');
                    return;
                else
                    warning('%s 알 수 없는 API 응답.', storedSymbols{s});
                    continue;
                end

                dates = fieldnames(dailyData);
                if isempty(dates)
                    warning('%s 날짜 데이터 없음.', storedSymbols{s});
                    continue;
                end

                latestDate = dates{1};
                entry = dailyData.(latestDate);

                if isfield(entry, '4. close')
                    price = str2double(entry.('4. close'));
                elseif isfield(entry, 'x4_Close')
                    price = str2double(entry.('x4_Close'));
                else
                    warning('%s 종가 필드 없음.', storedSymbols{s});
                    continue;
                end

                if ~isnan(price)
                    validStoredSymbols{end+1} = storedSymbols{s};
                    storedPrices(end+1) = price;
                    storedQuantities(end+1) = quantity(s);
                end
            catch ME
                warning('%s 데이터 가져오기 실패 (%s)', storedSymbols{s}, ME.message);
                continue;
            end
        end
    end

    % 직접 추가 입력
    prompt = {'추가할 종목 이름 (쉼표 구분, 없으면 비우기):', '수량 (쉼표 구분):', '가격 (쉼표 구분):'};
    answer = inputdlg(prompt, '직접 추가 입력', [1 60], {'','',''});

    directSymbols = {};
    directQuantities = [];
    directPrices = [];

    if ~isempty(answer) && ~isempty(strtrim(answer{1}))
        directSymbols = strtrim(strsplit(answer{1}, ','));
        directQuantities = str2double(strsplit(answer{2}, ','));
        directPrices = str2double(strsplit(answer{3}, ','));
    end

    % 🔹 API에서 정상적으로 가져온 저장된 심볼만 포함하도록 수정
    validSymbols = [validStoredSymbols, directSymbols];
    validQuantities = [storedQuantities, directQuantities];
    validPrices = [storedPrices, directPrices];

    end

if isempty(validSymbols)
    uialert(fig, '유효한 종목 데이터를 가져오지 못했습니다.', '오류', 'Icon', 'error');
    return;
end

% 자산 가치 및 비율 계산
if length(validPrices) ~= length(validQuantities)
    uialert(fig, '가격과 수량의 개수가 일치하지 않습니다.', '데이터 오류', 'Icon', 'error');
    return;
end

if any(isnan(validPrices)) || any(isnan(validQuantities))
    uialert(fig, '가격 또는 수량에 숫자가 아닌 값이 포함되어 있습니다.', '데이터 오류', 'Icon', 'error');
    return;
end

assetValues = validPrices .* validQuantities;
totalValue = sum(assetValues);

if totalValue <= 0
    uialert(fig, '모든 자산의 총 가치가 0입니다.', '경고', 'Icon', 'warning');
    return;
end

assetPercentage = (assetValues / totalValue) * 100;

% Pie Chart 생성
if ~isfield(fig.UserData, 'pieAxes') || ~isgraphics(fig.UserData.pieAxes)
    fig.UserData.pieAxes = uiaxes(fig, 'Position', [650, 200, 350, 400]);
end

pieAxes = fig.UserData.pieAxes;
cla(pieAxes);
drawnow;
pie(pieAxes, assetPercentage);

legendStrings = arrayfun(@(i) sprintf('%s: %.1f%%', validSymbols{i}, assetPercentage(i)), ...
                         1:numel(validSymbols), 'UniformOutput', false);

legend(pieAxes, legendStrings, 'Location', 'eastoutside');
title(pieAxes, ['Portfolio Allocation by Stock (', datestr(now,'yyyy-mm-dd'), ')']);

% 자산 비율 Pie Chart를 fig.UserData에 저장
fig.UserData.latestPortfolioData = struct(...
    'assetPercentage', assetPercentage, ...
    'legendStrings', legendStrings, ...
    'date', datestr(now, 'yyyy-mm-dd')...
);
    

end
