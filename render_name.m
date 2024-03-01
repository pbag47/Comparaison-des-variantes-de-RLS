function [rendered_name] = render_name(name)
    % For rendering purposes, the name of a variable can be modified to 
    % allow the LaTeX interpretor of figure titles and labels to
    % display proper symbols
    
    refactor_rules = {'Alg_', 'Algorithm ' ;
        '_noise', ' noise';
        'beta_R', '$\beta_\mathbf{R}$';
        'beta_Lambda', '$\beta_\mathbf{\Lambda}$';
        'beta_E', '$\beta_E$'} ;

    [number_of_rules, ~] = size(refactor_rules) ;
    rendered_name = name ;
    for i=1:number_of_rules
        rendered_name = strrep(rendered_name, refactor_rules{i, 1}, refactor_rules{i, 2}) ;
    end
end

