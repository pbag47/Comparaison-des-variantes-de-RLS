function Variables = find_variable_name(Results, Noise, Algorithm)
    fields = fieldnames(Results.(Noise).(Algorithm)) ;
    number_of_variables = length(fields) - 3 ;
    vi = 1 ; % Variable Index
    Variables = cell(number_of_variables, 1) ;
    for fi = 1:length(fields)
        field = fields{fi} ;
        if all([~strcmp(field, 'convergence'), ...
                ~strcmp(field, 'residuals'), ...
                ~strcmp(field, 'computing_time')])
            Variables{vi} = field ;
            vi = vi+1 ;
        end
    end
end