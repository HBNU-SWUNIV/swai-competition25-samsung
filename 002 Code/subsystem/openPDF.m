function openPDF(pdfFileName)
    % 현재 폴더에서 PDF 파일 찾기
    if exist(pdfFileName, 'file')
        % PDF 실행
        open(pdfFileName);
    else
        % 파일이 없을 경우 경고 메시지
        uialert(uifigure, ['파일이 없습니다: ' pdfFileName], '오류', 'Icon', 'error');
    end
end
