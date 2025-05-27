function apiGUI(mainFig)
 
    fig = uifigure('Name', 'API 입력 창', 'Position', [500, 300, 400, 250]);

   
    uilabel(fig, 'Text', 'API 입력:', 'Position', [30, 170, 120, 30]);

    
    inputField = uieditfield(fig, 'text', 'Position', [150, 170, 200, 30]);

   
    saveButton = uibutton(fig, 'push', ...
        'Text', '저장', ...
        'Position', [150, 120, 100, 40], ...
        'ButtonPushedFcn', @(btn, event) saveData(mainFig, inputField, fig));

    
    apiLinkButton = uibutton(fig, 'push', ...
        'Text', 'API 발급 링크', ...
        'Position', [50, 70, 130, 40], ...
        'ButtonPushedFcn', @(btn, event) web('https://www.alphavantage.co/support/#api-key', '-browser'));

    
    pdfButton = uibutton(fig, 'push', ...
        'Text', 'API 가이드 열기', ...
        'Position', [220, 70, 130, 40], ...
        'ButtonPushedFcn', @(btn, event) openPDF('api_guide.pdf'));
end
function saveData(mainFig, inputField, apiFig)
    
    str_data = inputField.Value; 
    


    
    dataStruct.text = str_data; 
    

   
    assignin('base', 'savedData', dataStruct);

   
    mainFig.UserData = dataStruct;

    
    uialert(mainFig, '데이터가 저장되었습니다! (Workspace에도 저장됨)', '완료', 'Icon', 'info');

  
    close(apiFig);
end