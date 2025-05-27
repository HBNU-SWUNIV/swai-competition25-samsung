function newFile(fig)
    % 저장된 데이터 초기화
    assignin('base', 'savedSymbols', {});
    assignin('base', 'savedData', []);

    fig.UserData.symbols = {};
    fig.UserData.symbolList.Items = {};

    if isfield(fig.UserData, 'pieAxes') && isgraphics(fig.UserData.pieAxes)
        cla(fig.UserData.pieAxes);
    end
    if isfield(fig.UserData, 'fxAxes') && isgraphics(fig.UserData.fxAxes)
        cla(fig.UserData.fxAxes);
    end
    if isfield(fig.UserData, 'fxPriceLabel') && isgraphics(fig.UserData.fxPriceLabel)
        fig.UserData.fxPriceLabel.Text = '최근 환율: 업데이트 필요';
    end

    uialert(fig, '새 파일이 초기화되었습니다.', '초기화 완료', 'Icon', 'success');
end
