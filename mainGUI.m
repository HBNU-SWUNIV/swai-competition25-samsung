function mainGUI
    clc; close all;
    addpath(genpath(fullfile(pwd, 'subsystem')));
    assignin('base', 'savedSymbols', {});  

    fig = uifigure('Name', 'ALTH', 'Position', [200, 100, 1000, 600]);


    symbolList = uilistbox(fig, 'Position', [220, 485, 250, 60], 'Items', {}, 'Multiselect', 'on');
    fig.UserData.symbolList = symbolList;
    fig.UserData.symbols = {};  % 심볼 배열


    uibutton(fig, 'push', 'Text', '1. API', 'Position', [15, 555, 80, 40], 'ButtonPushedFcn', @(btn, event) openApiGUI(fig));


    uibutton(fig, 'push', 'Text', '2. 종목탐색', 'Position', [110, 555, 80, 40], 'ButtonPushedFcn', @(btn, event) searchStock(fig));


    uilabel(fig, 'Text', '3. Symbol 입력:', 'Position', [220, 555, 100, 40]);
    symbolInput = uieditfield(fig, 'text', 'Position', [320, 555, 150, 40]);

    uibutton(fig, 'push', 'Text', '저장', 'Position', [490, 555, 70, 40], ...
             'ButtonPushedFcn', @(btn, event) saveSymbol(fig, symbolInput));

   
    uibutton(fig, 'push', 'Text', '선택 삭제', 'Position', [490, 485, 70, 60], ...
             'ButtonPushedFcn', @(btn, event) deleteSelectedSymbols(fig, symbolList));

 
    uibutton(fig, 'push', 'Text', '4. 가격 추정', 'Position', [600, 555, 80, 40], ...
             'ButtonPushedFcn', @(btn, event) predictStock(fig));

   
    fileMenu = uimenu(fig, 'Text', '파일');
    uimenu(fileMenu, 'Text', '새로 만들기', 'MenuSelectedFcn', @(src, event) newFile(fig));
    uimenu(fileMenu, 'Text', '저장하기', 'MenuSelectedFcn', @(src, event) saveFile(fig));
    uimenu(fileMenu, 'Text', '불러오기', 'MenuSelectedFcn', @(src, event) loadFile(fig));

 
    pieAxes = uiaxes(fig, 'Position', [600, 105, 350, 300]);
    title(pieAxes, 'Portfolio Allocation');
    fig.UserData.pieAxes = pieAxes;

    uibutton(fig, 'push', 'Text', '5. 자산 비율', 'Position', [700, 555, 80, 40], ...
             'ButtonPushedFcn', @(btn, event) showPortfolioPieChart(fig));

    uibutton(fig, 'push', 'Text', '차트 저장', 'Position', [600, 425, 100, 40], ...
             'ButtonPushedFcn', @(btn, event) savePieChart(fig));

   
    fxAxes = uiaxes(fig, 'Position', [50, 105, 500, 300]);
    title(fxAxes, 'USD/KRW Exchange Rate');
    ylabel(fxAxes, 'KRW per USD');
    grid(fxAxes, 'on');
    fig.UserData.fxAxes = fxAxes;

 
    uibutton(fig, 'push', 'Text', '환율 업데이트', 'Position', [50, 425, 120, 40], ...
             'ButtonPushedFcn', @(btn, event) updateFxData(fig));

    fxPriceLabel = uilabel(fig, 'Text', '최근 환율: 업데이트 필요', ...
                           'Position', [200, 425, 300, 40], 'FontSize', 14);
    fig.UserData.fxPriceLabel = fxPriceLabel;

    
    uiimage(fig, 'ImageSource', 'ALTHLogo.png', 'Position', [700, 1, 400, 120]);
    uiimage(fig, 'ImageSource', 'UI_05(2).jpg', 'Position', [50, 5, 250, 100]);

    
    uibutton(fig, 'push', ...
    'Text', '안정화', ...
    'Position', [15, 505, 80, 40], ...
    'ButtonPushedFcn', @(btn, event) restartMainGUI(fig));

end


function saveSymbol(fig, symbolInput)
    newSymbol = strtrim(symbolInput.Value);

    if isempty(newSymbol)
        uialert(fig, 'Symbol을 입력하세요!', '오류', 'Icon', 'warning');
        return;
    end

    if ~isfield(fig.UserData, 'symbols') || isempty(fig.UserData.symbols)
        fig.UserData.symbols = {};
    end

    symbols = fig.UserData.symbols;

    if ~ismember(newSymbol, symbols)
        symbols{end+1} = newSymbol;
        fig.UserData.symbols = symbols;

        assignin('base', 'savedSymbols', symbols);  % base 저장

        
        if isfield(fig.UserData, 'symbolList') && isvalid(fig.UserData.symbolList)
            fig.UserData.symbolList.Items = symbols;
            drawnow;  
        end

        uialert(fig, ['Symbol ' newSymbol '이(가) 저장되었습니다!'], '완료', 'Icon', 'info');
    else
        uialert(fig, ['Symbol ' newSymbol '은 이미 저장되었습니다!'], '알림', 'Icon', 'warning');
    end
end




function openApiGUI(mainFig)
    apiGUI(mainFig);
end

function restartMainGUI(fig)
    delete(fig);  
    pause(0.5);   
    mainGUI();    
end
