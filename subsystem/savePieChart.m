function savePieChart(fig)
    if ~isfield(fig.UserData, 'pieAxes') || ~isgraphics(fig.UserData.pieAxes)
        uialert(fig, '저장할 Pie Chart가 없습니다.', '오류', 'Icon', 'error');
        return;
    end

    [file,path] = uiputfile('*.jpg','Pie Chart 저장','PortfolioChart.jpg');
    if isequal(file,0) || isequal(path,0)
        return;
    end

    % Pie Chart 이미지로 저장
    exportgraphics(fig.UserData.pieAxes, fullfile(path,file), 'Resolution',300);
    uialert(fig, 'Pie Chart가 JPG 파일로 저장되었습니다.', '성공', 'Icon', 'success');
end