function [Vq, Xq, Yq, F] = plotPPF(para, resp)
% [Vq, Xq, Yq, F] = plotPPF(para, resp)

F = scatteredInterpolant(para, resp, 'natural', 'none');

[Xq,Yq] = meshgrid(linspace(0.95*min(para(:,1)), 1.1*max(para(:,1)),100),linspace( 0.95*min(para(:,2)), 1.1*max(para(:,2)),100));

Vq = F([Xq(:), Yq(:)]);
Vq = reshape(Vq,size(Xq,1), size(Xq,2));
imagesc(Xq(1,:)',Yq(:,1), Vq)
axis('xy')
% hold on
% plot(para(:,1), para(:,2), '.k')

