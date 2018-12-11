function [hrf,p] = spm_hrf(RT,P,T)
% Haemodynamic response function
% FORMAT [hrf,p] = spm_hrf(RT,p,T)
% RT   - scan repeat time
% p    - parameters of the response function (two Gamma functions)
%
%                                                           defaults
%                                                          {seconds}
%        p(1) - delay of response (relative to onset)          6
%        p(2) - delay of undershoot (relative to onset)       16
%        p(3) - dispersion of response                         1
%        p(4) - dispersion of undershoot                       1
%        p(5) - ratio of response to undershoot                6
%        p(6) - onset {seconds}                                0
%        p(7) - length of kernel {seconds}                    32
%
% T    - microtime resolution [Default: 16]
%
% hrf  - haemodynamic response function
% p    - parameters of the response function
%__________________________________________________________________________
% Copyright (C) 1996-2015 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_hrf.m 6594 2015-11-06 18:47:05Z guillaume $

% MODIFIED 20181211 by Baxter P Rogers to remove references to
% spm_get_defaults

%-Parameters of the response function
%--------------------------------------------------------------------------
p = P;

%-Microtime resolution
%--------------------------------------------------------------------------
fMRI_T = T;

%-Modelled haemodynamic response function - {mixture of Gammas}
%--------------------------------------------------------------------------
dt  = RT/fMRI_T;
u   = [0:ceil(p(7)/dt)] - p(6)/dt;
hrf = spm_Gpdf(u,p(1)/p(3),dt/p(3)) - spm_Gpdf(u,p(2)/p(4),dt/p(4))/p(5);
hrf = hrf([0:floor(p(7)/RT)]*fMRI_T + 1);
hrf = hrf'/sum(hrf);
