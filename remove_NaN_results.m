
clear variables
close all

data_file = 'Copy_of_Alg9_final.mat' ;

load(data_file, 'Results')

Noise_types = fieldnames(Results) ;
for nti = 1:length(Noise_types)
    Noise = Noise_types{nti} ;
    Algorithms = fieldnames(Results.(Noise)) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        nan_occurances = isnan(Results.(Noise).(Algorithm).convergence) ;
        number_of_nan = sum(nan_occurances) ;
        disp([Noise, ' | ', Algorithm, ' | ', num2str(number_of_nan), ' NaN results found. ', ...
            ' Total : ', num2str(length(Results.(Noise).(Algorithm).convergence)), ' simulations'])
        
        fields = fieldnames(Results.(Noise).(Algorithm)) ;
        for oi = length(nan_occurances):-1:1
            if nan_occurances(oi)
                for fi = 1:length(fields)
                    field = fields{fi} ;
                    Results.(Noise).(Algorithm).(field)(oi) = [] ;
                end
            end
        end
    end
end

save(data_file, 'Results')
