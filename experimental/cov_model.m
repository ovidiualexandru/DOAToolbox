function R = cov_model(P, sig, m, omega)
%Generate covariance matrix from formula
% R = APA* + sig^2*I;
%% Generate A matrix
A = exp(-1i*(-0:(m-1)).'*omega(:).');
%% Apply formula
R = A*P*A' + sig^2 * eye(m);
end