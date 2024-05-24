function Results = Sort_results(Results)
    Algorithms = fieldnames(Results) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        Noise_types = fieldnames(Results.(Algorithm)) ;
        for nti = 1:length(Noise_types)
            % Identification of the main variable
            Noise = Noise_types{nti} ;
            Variables = Functions.find_variable_name(Results, Algorithm, Noise) ;
            main_variable = Variables{1} ;

            % Sorting process to rearrange the results in an ascending 
            % order relatively to the variable
            [Results.(Algorithm).(Noise).(main_variable), I] = sort(Results.(Algorithm).(Noise).(main_variable)) ;
            Column_names = Results.(Algorithm).(Noise).Properties.VariableNames ;
            for ci = 1:length(Column_names)
                if ~strcmp(Column_names{ci}, main_variable)
                    Column_name = Column_names{ci} ;
                    Results.(Algorithm).(Noise).(Column_name) = Results.(Noise).(Algorithm).(Column_name)(I) ;
                end
            end
        end
    end
end