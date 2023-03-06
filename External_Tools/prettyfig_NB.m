function prettyfig_NB(varargin)

    % Defaults
    de_LW = 3;
    de_MS = 10;
    de_FS = 18;
    de_font = 'Times new Roman';
    
    p = inputParser;
    addParameter(p,'LW',de_LW);
    addParameter(p,'MS',de_MS);
    addParameter(p,'FS',de_FS);
    addParameter(p,'font',de_font);
    
    p.parse(varargin{:})
    res = p.Results;
    LW = res.LW;
    MS = res.MS;
    FS = res.FS;
    font = res.font;
    
    fh = gcf;
    
    de_size = get(0,'defaultfigureposition');
    
    if isequal(fh.Position, de_size)
        
        de_size = de_size.*[.2 .2 1.3 1.3];
        fh.Position = de_size;
        
    end
    
    h=get(gcf,'children');
    

    for ax_i = 1:length(h)
        
    if strcmp(class(h(ax_i)), 'matlab.graphics.axis.Axes')


%     yl=ylim(h(ax_i)); % retrieve auto y-limits
%      axis(h(ax_i), 'tight');   % set tight range
%     ylim(h(ax_i),[-inf inf])  % restore y limits 
  xlim('tight')

    set(findall(h(ax_i), 'Type', 'Line'),'LineWidth',LW);
    set(findall(h(ax_i), 'Type', 'Line'),'MarkerSize',MS);

    set(h(ax_i),'FontSize',FS);
    set(findall(gcf,'type','text'),'Fontsize',FS);
    set(findall(h(ax_i),'-Property','FontName'),'FontName',font);
    grid(h(ax_i),'on'); box(h(ax_i),'on');
    end

    
    end


end