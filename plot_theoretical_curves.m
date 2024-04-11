function plot_theoretical_curves(current_figure_number, save_figures, path)
    current_figure_number = current_figure_number + 1 ;
    
    %% Theoretical curves vs beta
    beta = linspace(0, 1, 200) ;
    theoretical_convergence_trendline = - 1 ./ log(beta) ;
    theoretical_error_trendline = sqrt((1 - beta) ./ (1 + beta)) ;
    
    %% Display
    figure(current_figure_number)

    % Convergence time
    subplot(2, 1, 1)
    plot(beta, theoretical_convergence_trendline, ...
        'LineStyle', '-', ...
        'Color', 'k', ...
        'Marker', 'none')
    title('\textbf{Theoretical convergence time trend-line}', ...
        'Interpreter','latex')
    xlim([0.4, 1])
    ylim([0, 100])
    xlabel('$ \beta $', ...
        'Interpreter', 'latex')
    ylabel({'Convergence time', ...
        '(arbitrary scaling)'}, ...
        'Interpreter', 'latex')

    % Residual error
    subplot(2, 1, 2)
    plot(beta, theoretical_error_trendline.^2, ...
        'LineStyle', '-', ...
        'Color', 'k', ...
        'Marker', 'none')
    title('\textbf{Theoretical residual error trend-line}', ...
        'Interpreter','latex')
    xlim([0.4, 1])
    xlabel('$ \beta $', ...
        'Interpreter', 'latex')
    ylabel({'Residual MSE ', ...
        '(arbitrary scaling)'}, ...
        'Interpreter', 'latex')

    % Figure format
    set(gcf, 'PaperUnits', 'centimeters', ...
        'PaperSize', [20, 15], ...
        'Units', 'centimeters', ...
        'Position', [5, 2, 20, 15])

    if save_figures
        % Export and save figure as pdf and fig files
        file = strcat(path, '\', 'Theoretical_curves') ;
        print(gcf, '-dpdf', '-bestfit', file)
        savefig(gcf, file)
    end
end

