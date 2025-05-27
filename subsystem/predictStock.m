function predictStock(fig)
   
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

    
    if evalin('base', 'exist(''savedSymbols'', ''var'')')
        savedSymbols = evalin('base', 'savedSymbols');
        if isempty(savedSymbols)
            uialert(fig, '저장된 Symbol이 없습니다. 먼저 Symbol을 입력하세요.', '오류', 'Icon', 'error');
            return;
        end
    else
        uialert(fig, '저장된 Symbol이 없습니다. 먼저 Symbol을 입력하세요.', '오류', 'Icon', 'error');
        return;
    end

  
    for s = 1:length(savedSymbols)
        symbol = savedSymbols{s};
        functionType = 'TIME_SERIES_DAILY';

        url = ['https://www.alphavantage.co/query?function=' functionType ...
               '&symbol=' symbol '&apikey=' apiKey];

        try
            response = webread(url);

           
            if isfield(response, 'Time Series (Daily)')
                dailyData = response.('Time Series (Daily)');
            elseif isfield(response, 'TimeSeries_Daily_')
                dailyData = response.('TimeSeries_Daily_');
            else
                warning(['API에서 데이터를 가져올 수 없습니다: ' symbol]);
                continue;
            end

            
            dates = fieldnames(dailyData);
            numEntries = length(dates);

            openPrices = NaN(numEntries, 1);
            highPrices = NaN(numEntries, 1);
            lowPrices = NaN(numEntries, 1);
            closePrices = NaN(numEntries, 1);
            volume = NaN(numEntries, 1);

            for i = 1:numEntries
                currentDate = dates{i};
                entry = dailyData.(currentDate);

                if isfield(entry, '1. open')
                    openPrices(i) = str2double(entry.('1. open'));
                elseif isfield(entry, 'x1_Open')
                    openPrices(i) = str2double(entry.('x1_Open'));
                end

                if isfield(entry, '2. high')
                    highPrices(i) = str2double(entry.('2. high'));
                elseif isfield(entry, 'x2_High')
                    highPrices(i) = str2double(entry.('x2_High'));
                end

                if isfield(entry, '3. low')
                    lowPrices(i) = str2double(entry.('3. low'));
                elseif isfield(entry, 'x3_Low')
                    lowPrices(i) = str2double(entry.('x3_Low'));
                end

                if isfield(entry, '4. close')
                    closePrices(i) = str2double(entry.('4. close'));
                elseif isfield(entry, 'x4_Close')
                    closePrices(i) = str2double(entry.('x4_Close'));
                end

                if isfield(entry, '5. volume')
                    volume(i) = str2double(entry.('5. volume'));
                elseif isfield(entry, 'x5_Volume')
                    volume(i) = str2double(entry.('x5_Volume'));
                end
            end

           
            openPrices = flip(openPrices);
            highPrices = flip(highPrices);
            lowPrices = flip(lowPrices);
            closePrices = flip(closePrices);
            volume = flip(volume);
            cleanedDates = erase(dates, 'x');
            convertedDates = datetime(cleanedDates, 'InputFormat', 'yyyy_MM_dd');
            convertedDates = flip(convertedDates);

            
            urlOverview = ['https://www.alphavantage.co/query?function=OVERVIEW&symbol=' symbol '&apikey=' apiKey];
            overviewData = webread(urlOverview);

            if isfield(overviewData, 'PERatio') && isfield(overviewData, 'PriceToBookRatio') && isfield(overviewData, 'ReturnOnEquityTTM')
                per = str2double(overviewData.PERatio);
                pbr = str2double(overviewData.PriceToBookRatio);
                roe = str2double(overviewData.ReturnOnEquityTTM);
                profitMargin = str2double(overviewData.ProfitMargin);
                analystTargetPrice = str2double(overviewData.AnalystTargetPrice);
            else
                per = NaN; pbr = NaN; roe = NaN;
                profitMargin = NaN; analystTargetPrice = NaN;
            end

            shortMA = movmean(closePrices, 10);
            longMA = movmean(closePrices, 50);
            buySignal = (shortMA > longMA) & (circshift(shortMA,1) <= circshift(longMA,1));
            sellSignal = (shortMA < longMA) & (circshift(shortMA,1) >= circshift(longMA,1));

            [macdLine, signalLine] = macd(closePrices);
            buySignalMACD = (macdLine > signalLine) & (circshift(macdLine,1) <= circshift(signalLine,1));
            sellSignalMACD = (macdLine < signalLine) & (circshift(macdLine,1) >= circshift(signalLine,1));

            features = [volume, highPrices, lowPrices];
            target = closePrices;
            train_size = floor(0.8 * length(target));
            trainX = features(1:train_size, :);
            trainY = target(1:train_size);
            testX = features(train_size+1:end, :);
            testY = target(train_size+1:end);
            model = fitlm(trainX, trainY);
            predictedPrice = predict(model, testX);
            futureDays = 1;
            lastDate = convertedDates(end);
            futureDates = lastDate + days(1:futureDays);
            lastFeature = features(end, :);
            futureFeatures = repmat(lastFeature, futureDays, 1);
            futurePredictions = predict(model, futureFeatures);

           
fig = figure('Units', 'normalized', 'Position', [0.2, 0.2, 0.8, 0.7], ...
    'Name', symbol, 'NumberTitle', 'off');

leftPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0 0 0.8 1]);
rightPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.8 0 0.2 1]);


t = tiledlayout(leftPanel, 4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');


nexttile(t); hold on;
for i = 1:length(openPrices)
    if closePrices(i) > openPrices(i)
        line([i, i], [lowPrices(i), highPrices(i)], 'Color', 'r', 'LineWidth', 1.5);
        rectangle('Position', [i - 0.25, openPrices(i), 0.5, closePrices(i) - openPrices(i)], ...
            'FaceColor', 'r', 'EdgeColor', 'r');
    else
        line([i, i], [lowPrices(i), highPrices(i)], 'Color', 'b', 'LineWidth', 1.5);
        rectangle('Position', [i - 0.25, closePrices(i), 0.5, openPrices(i) - closePrices(i)], ...
            'FaceColor', 'b', 'EdgeColor', 'b');
    end
end
hold off;
ylabel('Price (USD)');
title([symbol ' Stock Prices (Candlestick)']);

grid on;
xticks(1:round(length(convertedDates)/10):length(convertedDates));
xticklabels(datestr(convertedDates(1:round(length(convertedDates)/10):end), 'yyyy-mm-dd'));
xlim([1, length(convertedDates)]);
ylim([min(lowPrices) - 5, max(highPrices) + 5]);


nexttile(t); hold on;
plot(convertedDates, closePrices, 'k', 'LineWidth', 1.5);
plot(convertedDates, shortMA, 'r', 'LineWidth', 1.2);
plot(convertedDates, longMA, 'b', 'LineWidth', 1.2);
scatter(convertedDates(buySignal), closePrices(buySignal), 50, 'g', 'filled');
scatter(convertedDates(sellSignal), closePrices(sellSignal), 50, 'r', 'filled');
title('Stock Prices with Moving Averages');
grid on;
lgd = legend('Close Price', 'Short MA (10-day)', 'Long MA (50-day)', 'Buy Signal', 'Sell Signal');
lgd.Orientation = 'horizontal';
lgd.Position = [0.07 0.5 0.7 0.03];


nexttile(t); hold on;
plot(convertedDates, macdLine, 'b', 'LineWidth', 1.5);
plot(convertedDates, signalLine, 'r', 'LineWidth', 1.2);
scatter(convertedDates(buySignalMACD), macdLine(buySignalMACD), 50, 'g', 'filled');
scatter(convertedDates(sellSignalMACD), macdLine(sellSignalMACD), 50, 'r', 'filled');
title('MACD Indicator');
grid on;
lgd = legend('MACD', 'Signal', 'Buy Signal', 'Sell Signal');
lgd.Orientation = 'horizontal';
lgd.Position = [0.07 0.25 0.7 0.03];


nexttile(t); hold on;
plot(convertedDates(train_size+1:end), testY, 'b', 'LineWidth', 1.5);
plot(convertedDates(train_size+1:end), predictedPrice, 'r', 'LineWidth', 1.5);
plot([convertedDates(end); futureDates], [predictedPrice(end); futurePredictions], '--m', 'LineWidth', 1.5);
scatter(futureDates, futurePredictions, 50, 'm', 'filled');
title('Stock Price Prediction');
grid on;
lgd = legend('Actual Price', 'Predicted Price', 'Extended Prediction');
lgd.Orientation = 'horizontal';
lgd.Position = [0.07 0.01 0.7 0.03];


infoPanel = uipanel('Parent', rightPanel, 'Title', 'Stock Information', ...
    'FontSize', 12, 'BackgroundColor', 'w', 'Units', 'normalized', 'Position', [0.05, 0.1, 0.9, 0.8]);

infoText = sprintf('PER: %.1f\nPBR: %.2f\nROE: %.1f%%\nProfit Margin: %.2f%%\nTarget Price: $%.2f', ...
    per, pbr, roe, profitMargin, analystTargetPrice);

uicontrol('Parent', infoPanel, 'Style', 'text', ...
    'String', infoText, 'FontSize', 12, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8], 'HorizontalAlignment', 'left');
        catch ME
            warning(['API 요청 중 오류 발생: ', ME.message]);
        end
    end
    drawnow expose update;
end
