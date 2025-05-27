function updateFxData(fig)
    
    if ~isfield(fig.UserData, 'fxAxes') || isempty(fig.UserData.fxAxes) || ~isvalid(fig.UserData.fxAxes)
    uialert(fig, '환율 그래프를 표시할 축(fxAxes)이 준비되지 않았습니다.', '오류', 'Icon', 'error');
    return;
    
    end
   

   
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

    
    url = ['https://www.alphavantage.co/query?function=FX_DAILY&from_symbol=USD&to_symbol=KRW&apikey=' apiKey];

    try
        fxData = webread(url);

       
        if isfield(fxData, 'Time Series FX (Daily)')
            fxDaily = fxData.('Time Series FX (Daily)');
        elseif isfield(fxData, 'TimeSeriesFX_Daily_')
            fxDaily = fxData.('TimeSeriesFX_Daily_');
        else
            uialert(fig, '환율 데이터를 가져올 수 없습니다.', '오류', 'Icon', 'error');
            return;
        end

        
        fxDates = fieldnames(fxDaily);
        numDays = length(fxDates);

        openPrices = NaN(numDays, 1);
        highPrices = NaN(numDays, 1);
        lowPrices = NaN(numDays, 1);
        closePrices = NaN(numDays, 1);
        convertedDates = datetime([], [], []);

        for i = 1:numDays
            rawDate = fxDates{i};
            cleanDate = erase(rawDate, 'x');
            cleanDate = strrep(cleanDate, '_', '-');
            convertedDates(i) = datetime(cleanDate, 'InputFormat', 'yyyy-MM-dd');

            entry = fxDaily.(fxDates{i});
            fields = fieldnames(entry);

            for j = 1:length(fields)
                field = lower(fields{j});
                if contains(field, 'open')
                    openPrices(i) = str2double(entry.(fields{j}));
                elseif contains(field, 'high')
                    highPrices(i) = str2double(entry.(fields{j}));
                elseif contains(field, 'low')
                    lowPrices(i) = str2double(entry.(fields{j}));
                elseif contains(field, 'close')
                    closePrices(i) = str2double(entry.(fields{j}));
                end
            end
        end

       
        openPrices = flip(openPrices);
        highPrices = flip(highPrices);
        lowPrices = flip(lowPrices);
        closePrices = flip(closePrices);
        convertedDates = flip(convertedDates);

        
        if isfield(fig.UserData, 'fxAxes') && isvalid(fig.UserData.fxAxes)
    fxAxes = fig.UserData.fxAxes;
else
    uialert(fig, '환율 그래프를 표시할 축(fxAxes)이 준비되지 않았습니다.', '오류', 'Icon', 'error');
    return;
end
        cla(fxAxes);
        hold(fxAxes, 'on');

        for i = 1:length(openPrices)
            
            plot(fxAxes, [i i], [lowPrices(i), highPrices(i)], 'Color', 'k', 'LineWidth', 1.2);

           
            if closePrices(i) > openPrices(i)
                rectangle(fxAxes, 'Position', [i-0.25, openPrices(i), 0.5, closePrices(i)-openPrices(i)], ...
                          'FaceColor', 'r', 'EdgeColor', 'r');
            else
                rectangle(fxAxes, 'Position', [i-0.25, closePrices(i), 0.5, openPrices(i)-closePrices(i)], ...
                          'FaceColor', 'b', 'EdgeColor', 'b');
            end
        end

        hold(fxAxes, 'off');

        
        ylabel(fxAxes, 'KRW per USD');
        title(fxAxes, 'USD/KRW Exchange Rate (Candlestick)');
        grid(fxAxes, 'on');

        xticks(fxAxes, 1:round(length(convertedDates)/10):length(convertedDates));
        xticklabels(fxAxes, datestr(convertedDates(1:round(length(convertedDates)/10):end), 'yyyy-mm-dd'));
        xlim(fxAxes, [1, length(convertedDates)]);
        ylim(fxAxes, [min(lowPrices)-5, max(highPrices)+5]);

    catch ME
        uialert(fig, ['API 요청 중 오류 발생: ' ME.message], '오류', 'Icon', 'error');
    end
    fig.UserData.latestFxPrice = closePrices(end);

    
if isfield(fig.UserData, 'fxPriceLabel') && isvalid(fig.UserData.fxPriceLabel)
    fig.UserData.fxPriceLabel.Text = sprintf('최근 환율: %.2f KRW/USD', closePrices(end));
end
end
