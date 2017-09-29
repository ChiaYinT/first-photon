function R = rotx(beta)
R = [  1 0 0;  0 cosd(beta) -sind(beta);0 sind(beta) cosd(beta)];
end