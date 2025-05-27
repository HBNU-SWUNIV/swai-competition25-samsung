function restorePortfolioPieChart(fig, portfolioData)
    pieAxes = fig.UserData.pieAxes;
    cla(pieAxes);
    
    % 저장된 데이터를 그래프에 복원
    pie(pieAxes, portfolioData.assetPercentage);
    
    legendStrings = portfolioData.legendStrings;
    legend(pieAxes, legendStrings, 'Location', 'eastoutside');
    
    title(pieAxes, ['Portfolio Allocation (', portfolioData.date, ')']);
end