function Variables = find_variable_name(Results, Algorithm, Noise)
    Column_names = Results.(Algorithm).(Noise).Properties.VariableNames ;
    number_of_variables = length(Column_names) - 3 ;
    vi = 1 ; % Variable Index
    Variables = cell(number_of_variables, 1) ;
    for ci = 1:length(Column_names)
        Column_name = Column_names{ci} ;
        if all([~strcmp(Column_name, 'convergence'), ...
                ~strcmp(Column_name, 'residuals'), ...
                ~strcmp(Column_name, 'computing_time')])
            Variables{vi} = Column_name ;
            vi = vi+1 ;
        end
    end
end