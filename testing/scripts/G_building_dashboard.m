    %using tiledlayout https://www.mathworks.com/help/matlab/ref/tiledlayout.html

    h1= openfig([data_path subject_list{s} '_rt_hit_boxpl.fig']);
    
    ax1=gca;
    h2= openfig([data_path subject_list{s} '_rt_fa_boxpl.fig']);
    ax2=gca;
    h3= openfig([data_path subject_list{s} '_hit_erp.fig']);
    ax3=gca;
    xlim auto
    h4= openfig([data_path subject_list{s} '_correct rejection o-o_erp.fig']);
    ax4=gca;
    legend('2*Sin(x)')
    h5=openfig([data_path subject_list{s} '_correct rejection o-a_erp.fig']);
    ax5=gca;
    h6=openfig([data_path subject_list{s} '_correct rejection active_erp.fig']);
    ax6=gca;
    

    
    h7=figure('units','normalized','outerposition',[0 0 1 1]);
    s1 = subplot(3,3,1); %create and get handle to the subplot axes
    title('All RTs Hits binned by time')
    set(s1,'XTickLabel',{' ', '1/4',' ', '2/4',' ', '3/4',' ',  '4/4',' ' })
    s2 = subplot(3,3,2);
    title('All RTs FAs binned by type')
    
    s3 = subplot(3,3,3);
    s4 = subplot(3,3,4);
    s5 = subplot(3,3,5);
    s6 = subplot(3,3,6);
    fig1 = get(ax1,'children'); %get handle to all the children in the figure
    fig2 = get(ax2,'children');
    fig3 = get(ax3,'children'); %get handle to all the children in the figure
    fig4 = get(ax4,'children');
    fig5 = get(ax5,'children'); %get handle to all the children in the figure
    fig6 = get(ax6,'children');
    copyobj(fig1,s1); %copy children to new parent axes i.e. the subplot axes
    copyobj(fig2,s2);
    copyobj(fig3,s3); %copy children to new parent axes i.e. the subplot axes
    copyobj(fig4,s4);
    copyobj(fig5,s5); %copy children to new parent axes i.e. the subplot axes
    copyobj(fig6,s6);
 
    
    
    
    
    tcl=tiledlayout(3,6);
    ax1.Parent=tcl;
    ax1.Layout.Tile=[1 2];
    ax2.Parent=tcl;
    ax2.Layout.Tile=3;
    
    ax3.Parent=tcl;
    ax3.Layout.Tile=3;
    ax4.Parent=tcl;
    ax4.Layout.Tile=4;
    ax5.Parent=tcl;
    ax5.Layout.Tile=5;
    ax6.Parent=tcl;
    ax6.Layout.Tile=6;