function [Error, t] = Alg_7_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
%     global Sh

    %% Initialization
    lambda = variables(1) ;
    delta = variables(2) ;
    t = NaN ;
    epsilon = 2 ;
    Error = zeros(length(Input), 1) ;
%     Output = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    Lambda = 2*eye(filter_length, filter_length) ;
%     Omega = 2*ones(filter_length, 1) ;
    H_transform = zeros(filter_length, 1) ;
%     H = zeros(filter_length, 1) ;
%     Omega = 2*ones(filter_length/2+1, 1) ;
%     H_transform = zeros(filter_length/2+1, 1) ;
    
    R = zeros(filter_length, filter_length) ;
%     eigenvectors = eye(filter_length) ;
%     eigenvectors = 1/sqrt(filter_length) * dftmtx(filter_length) ;
%     eigenvalues = eye(filter_length) ;
    lambda_R = 0.9 ;

    %% Proposed DFTLMS algorithm, separated memory factors
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        
        
%         
% /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ 
%         Ne pas utiliser ' pour transposer des vecteurs ou matrices
%         complexes !
%         Par d�faut, ' prend la transpos�e conjugu�e  
% /!\ /!\ /!\/!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ 
%         


% % Etape 1, depuis l'expression r�cursive du filtre de Wiener
        R = (1-lambda_R) * transpose(X) * X + lambda_R * R ;
%         Output(i) = X * H ;
%         Error(i) = Expected_result(i) - Output(i) ;
%         if i > ANC_start_sample + filter_length
%             H = H + (1-lambda) * Error(i) * R^(-1) * transpose(X) ;
%         end
% % Fonctionne pour des valeurs de lambda comprises dans 
% %   -   [0.85, 1[ si L=32     <- R�glage par d�faut
% %   -   [0.8, 1[ si L=16
        
% % Etape 2, Diagonalisation de R
%         R = (1-lambda_R) * transpose(X) * X + lambda_R * R ;
%         Output(i) = X * H ;
%         Error(i) = Expected_result(i) - Output(i) ;
%         if i > ANC_start_sample + filter_length
%             [eigenvectors, eigenvalues] = eig(R) ;
%             H = H + (1-lambda) * Error(i) * (eigenvectors * eigenvalues * eigenvectors^(-1))^(-1) * transpose(X) ;
%         end
% % Fonctionne pour des valeurs de lambda comprises dans [0.85, 1[
        
% % Etape 3, Projection de H dans la base des vecteurs propres de R
%         R = (1-lambda_R) * transpose(X) * X + lambda_R * R ;
%         Output(i) = X * H ;
%         Error(i) = Expected_result(i) - Output(i) ;
%         if i > ANC_start_sample + filter_length
%             [eigenvectors, eigenvalues] = eig(R) ;
%             H_transform = eigenvectors * H ;  % <- N�cessit� car eigenvectors change � chaque it�ration
%             H_transform = H_transform + (1-lambda) * Error(i) * eigenvectors * eigenvectors * eigenvalues^(-1) * ...
%                 eigenvectors^(-1) * transpose(X) ;
%             H = eigenvectors^(-1) * H_transform ;
%         end
% % Fonctionne pour des valeurs de lambda comprises dans [0.85, 1[,
% % mais l'erreur r�siduelle est �lev�e

% % Etape 4, Projection de l'�quation du filtre dans la base des vecteurs propres de R
%         R = (1-lambda_R) * transpose(X) * X + lambda_R * R ;
%         if i > ANC_start_sample + filter_length
%             [eigenvectors, eigenvalues] = eig(R) ;
%             Output(i) = X * eigenvectors^(-1) * H_transform  ;
%             Error(i) = Expected_result(i) - Output(i) ;
%             H_transform = H_transform + (1-lambda) * Error(i) * eigenvectors * eigenvectors * eigenvalues^(-1) * ...
%                 eigenvectors^(-1) * transpose(X) ;
%         end
% % Ne fonctionne pas : Puisque les valeurs et vecteurs propres
% % sont recalcul�s � chaque it�ration, l'effet m�moire de
% % H_transform n'est jamais associ� � la base utilis�e pour X
        
% % Etape 5, Projection de H dans une base orthogonale invariante
% % /!\ La matrice eigenvalues n'est plus forc�ment diagonale ! /!\
%         R = (1-lambda_R) * transpose(X) * X + lambda_R * R ;
%         if i == ANC_start_sample + 2 * filter_length
%             [eigenvectors, eigval] = eig(R) ;
%             eigenvalues = diag(diag(eigval)) ;
%         end
%         if i > ANC_start_sample + 2*filter_length
%             eigenvalues = (1-delta) * (eigenvectors^(-1) * transpose(X)) * (X * eigenvectors) + delta * eigenvalues ;
%             Output(i) = X * eigenvectors^(-1) * H_transform  ;
%             Error(i) = Expected_result(i) - Output(i) ;
%             H_transform = H_transform + (1-lambda) * Error(i) * eigenvectors * eigenvectors * eigenvalues^(-1) * ...
%                 eigenvectors^(-1) * transpose(X) ;
%         end
% % Fonctionne pour lambda compris dans [0.85, 1[

% % Etape 6, On n�glige les termes extra-diagonaux de la matrice eigenvalues
%         R = (1-lambda_R) * transpose(X) * X + lambda_R * R ;
%         if i == ANC_start_sample + 2 * filter_length
%             [eigenvectors, eigval] = eig(R) ;
%             eigenvalues = diag(diag(eigval)) ;
%         end
%         if i > ANC_start_sample + 2*filter_length
%             eigenvalues = (1-delta) * (eigenvectors^(-1) * transpose(X)) * (X * eigenvectors) + delta * eigenvalues ;
%             Output(i) = X * eigenvectors^(-1) * H_transform  ;
%             Error(i) = Expected_result(i) - Output(i) ;
%             H_transform = H_transform + (1-lambda) * Error(i) * eigenvectors * eigenvectors *  diag(diag(eigenvalues))^(-1) * ...
%                 eigenvectors^(-1) * transpose(X) ;
%         end
% % Fonctionne pour lambda compris dans [0.95, 1[

% Etape 7, Changement de base pour utiliser la DFT
%         % --- Version pr�sent�e dans l'article --- %
%         X_transform = fft(X) / sqrt(filter_length) ;
%         Lambda = (1-delta) * diag(X_transform.*conj(X_transform)) + delta*Lambda ;
%         Error(i) = Expected_result(i) - real(conj(X_transform) * H_transform) ;
%         H_transform = H_transform + (1-lambda)*epsilon/filter_length * Error(i) * diag(diag(Lambda).^(-1)) * transpose(X_transform) ;
%         % --- -------------------------------- --- %
        
        % --- Prise en compte des �l�ments extra-diagonaux de Lambda  --- %
        X_transform = fft(X) / sqrt(filter_length) ;
        Lambda = (1-delta) * transpose(X_transform)*conj(X_transform) + delta*Lambda ;
%         Lambda_diag = (1-delta) * diag(X_transform.*conj(X_transform)) + delta*Lambda ;
        Error(i) = Expected_result(i) - real(conj(X_transform) * H_transform) ;
        step_diag = (1-lambda)*epsilon/filter_length * Error(i) * diag(diag(Lambda).^(-1)) * transpose(X_transform) ;
        step_extra_diag = (1-lambda)*epsilon/filter_length * Error(i) * Lambda^(-1) * transpose(X_transform) ;
        H_transform = H_transform + step_diag ;
        
        figure(1002)
        subplot(2, 1, 1)
        hold off
        plot(real(step_extra_diag))
        hold on
        plot(real(step_diag))
        title('Influence of the non-diagonal elements of \Lambda_n on the algorithm step-size')
        xlabel('Component number')
        ylabel('Real part of the step size')
        
        subplot(2, 1, 2)
        hold off
        plot(imag(step_extra_diag))
        hold on
        plot(imag(step_diag))
        legend('Step size with full matrix \Lambda_n', 'Step size by approximating \Lambda_n as diagonal')
        xlabel('Component number')
        ylabel('Imaginary part of the step size')
        
        set(gcf, 'PaperUnits', 'centimeters', ...
            'PaperSize', [20, 15], ...
            'Units', 'centimeters', ...
            'Position', [5, 2, 20, 15])
        % --- ------------------------------------------------------- --- %
        
%         % --- Version optimis�e au niveau du temps de calcul --- %
% %         X_transform = fft(X) / sqrt(filter_length) ;
%         X_transform = fft(X) ;
%         Omega = (1-delta) * transpose(conj(X_transform).*X_transform) + delta*Omega ;
%         Error(i) = Expected_result(i) - real(conj(X_transform) * H_transform) ;
%         H_transform = H_transform + (1-lambda) *(1/filter_length)* Error(i) * Omega.^(-1) .* transpose(X_transform) ;
% %         H_transform = H_transform + (1-lambda) * Error(i) * Omega.^(-1) .* transpose(X_transform) ;
%         % --- ---------------------------------------------- --- %

%         % --- Version visant � �liminer les redondances --- %
%         X_transform = fft(X) / sqrt(filter_length) ;
%         X_split = X_transform(1:filter_length/2+1) ;
%         X_split_conj = conj(X_split) ;
%         Omega = (1-delta) * 2*transpose(X_split_conj.*X_split) + delta*Omega ;
%         Error(i) = Expected_result(i) - 2*real(X_split_conj * H_transform) ;
%         H_transform = H_transform + (1-lambda)/filter_length * Error(i) * Omega.^(-1) .* transpose(X_split) ;
%         % --- ----------------------------------------- --- %

%         % --- I-DFT LMS --- %
%         X_transform = ifft(X) * sqrt(filter_length) ;
% %         X_transform = fft(X) ;
%         Omega = (1-delta) * transpose(conj(X_transform).*X_transform) + delta*Omega ;
%         Error(i) = Expected_result(i) - real(conj(X_transform) * H_transform) ;
%         H_transform = H_transform + (1-lambda) *(1/filter_length)* Error(i) * Omega.^(-1) .* transpose(X_transform) ;
% %         H_transform = H_transform + (1-lambda) * Error(i) * Omega.^(-1) .* transpose(X_transform) ;
%         % --- --------- --- %
        
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
    
%     eigenvalues = eig(R) ;
%     figure(1000)
%     plot(sort(eigenvalues))
%     hold on
% %     plot(1:2:filter_length+1, sort(Omega))
%     plot(sort(Omega))

%     figure(1001)
%     subplot(2, 1, 1)
%     plot(real(H_transform))
%     subplot(2, 1, 2)
%     plot(imag(H_transform))

%     figure(1002)
%     plot(Error)
end