function Print_results(filename, save_figures)
    load(filename, 'Results')
    path = "C:\Users\P_Bagnara\Desktop\BAGNARA Pierre\Rédaction d'article\An intuitive approach to study LS convergence\Images" ;
    current_figure_number = 1 ;
    
    current_figure_number = plot_performance_comparison(Results, current_figure_number, save_figures, path) ;
    current_figure_number = plot_individual_results(Results, current_figure_number, save_figures, path) ;
end