function Results = Sort_results(Results)
    Noise_types = fieldnames(Results) ;
    for nti = 1:length(Noise_types)
        Noise = Noise_types{nti} ;
        Algorithms = fieldnames(Results.(Noise)) ;
        for ai = 1:length(Algorithms)
            % Identification of the variable
            Algorithm = Algorithms{ai} ;
            fields = fieldnames(Results.(Noise).(Algorithm)) ;
            Variables = find_variable_name(Results, Noise, Algorithm) ;
            main_variable = Variables{1} ;
            
            % Sorting process to rearrange the results in an ascending 
            % order relatively to the variable
            [Results.(Noise).(Algorithm).(main_variable), I] = sort(Results.(Noise).(Algorithm).(main_variable)) ;
            for fi = 1:length(fields)
                if ~strcmp(fields{fi}, main_variable)
                    Results.(Noise).(Algorithm).(fields{fi}) = Results.(Noise).(Algorithm).(fields{fi})(I) ;
                end
            end
        end
    end
end