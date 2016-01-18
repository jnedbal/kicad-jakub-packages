fn = 'CTB0308';
folder = '/usr/brlcad/bin/';

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');

% nubmer of terminals
nrT = 2;
% width
w = [NaN, 7.6, 11.4, 15.2, 19.1, 22.9, 26.7, 30.5, 34.3, 38.1, 41.9, 45.7];

%% connector body

H = [-w(nrT) / 2 -3.5 0, w(nrT) / 2 -3.5 0, w(nrT) / 2 3.5 0, -w(nrT) / 2 3.5 0];
H = [H, H + [0 0 4.6, 0 0 4.6, 0 0 4.6, 0 0 4.65]];
fprintf(fid, 'in body1s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [H(13 : end), H(13 : end) + [0 0.5 4.5, 0 0.5 4.5, 0 -0.5 4.5, 0 -0.5 4.5]];
fprintf(fid, 'in body2s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

% notches
H = [w(nrT) / 2, -2.5, 4.1, w(nrT) / 2 + 0.25, -2.75, 4.1, w(nrT) / 2 + 0.25, -2, 4.1, w(nrT) / 2, -2.25, 4.1];
H = [H, H + [0 0 5, 0 0 5, 0 0 5, 0 0 5]];
fprintf(fid, 'in body3s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [w(nrT) / 2, 2.5, 4.1, w(nrT) / 2 + 0.25, 2.75, 4.1, w(nrT) / 2 + 0.25, 2, 4.1, w(nrT) / 2, 2.25, 4.1];
H = [H, H + [0 0 5, 0 0 5, 0 0 5, 0 0 5]];
fprintf(fid, 'in body4s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

% holes in body
% holes for screws
for i = 1 : nrT
    fprintf(fid, 'in body%dh.s rcc %g %g %g   %g %g %g   %g\n', [i, -(nrT + 1) / 2 * 3.81 + i * 3.81, 0, 9.2, 0, 0 -3.1, 1.5]);
end

% holes for cable
for i = 1 : nrT
    H = (-(nrT + 1) / 2 * 3.81 + i * 3.81) * [1 0 0, 1 0 0, 1 0 0, 1 0 0] + [-1 -3.5 2, 1 -3.5 2, 1 -3.5 4, -1 -3.5 4];
    H = [H, H + [0 3 0, 0 3 0, 0 3 0, 0 3 0]];
    fprintf(fid, 'in body%dh.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', [nrT + i, H]);
end

% notches
H = [-w(nrT) / 2, -2.5, 4.1, -w(nrT) / 2 + 0.25, -2.75, 4.1, -w(nrT) / 2 + 0.25, -2, 4.1, -w(nrT) / 2, -2.25, 4.1];
H = [H, H + [0 0 6, 0 0 6, 0 0 6, 0 0 6]];
fprintf(fid, 'in body%dh.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', [2 * nrT + 1, H]);

H = [-w(nrT) / 2, 2.5, 4.1, -w(nrT) / 2 + 0.25, 2.75, 4.1, -w(nrT) / 2 + 0.25, 2, 4.1, -w(nrT) / 2, 2.25, 4.1];
H = [H, H + [0 0 6, 0 0 6, 0 0 6, 0 0 6]];
fprintf(fid, 'in body%dh.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', [2 * nrT + 2, H]);


% join regions
fprintf(fid, 'r bodys.r');
for i = 1 : 4
    fprintf(fid, ' u body%ds.s', i);
end
fprintf(fid, '\n');
fprintf(fid, 'r bodyh.r');
for i = 1 : (2 * nrT + 2)
    fprintf(fid, ' u body%dh.s', i);
end
fprintf(fid, '\n');

% Metallic materials
% screws
for i = 1 : nrT
    fprintf(fid, 'in metal%ds.s rcc %g %g %g   %g %g %g   %g\n', [i, -(nrT + 1) / 2 * 3.81 + i * 3.81, 0, 6.1, 0, 0, 2, 1.5]);
end

% cable connectors
for i = 1 : nrT
    H = (-(nrT + 1) / 2 * 3.81 + i * 3.81) * [1 0 0, 1 0 0, 1 0 0, 1 0 0] + [-1 -2.5 2, 1 -2.5 2, 1 -2.5 4, -1 -2.5 4];
    H = [H, H + [0 2 0, 0 2 0, 0 2 0, 0 2 0]];
    fprintf(fid, 'in metal%ds.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', [nrT + i, H]);
end

% Metallic material holes

% cable connector holes
for i = 1 : nrT
    H = (-(nrT + 1) / 2 * 3.81 + i * 3.81) * [1 0 0, 1 0 0, 1 0 0, 1 0 0] + [-0.75 -2.5 2.25, 0.75 -2.5 2.25, 0.75 -2.5 3.75, -0.75 -2.5 3.75];
    H = [H, H + [0 1 0, 0 1 0, 0 1 0, 0 1 0]];
    fprintf(fid, 'in metal%dh.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', [i, H]);
end

% screwdriver holes
for i = 1 : nrT
    H = (-(nrT + 1) / 2 * 3.81 + i * 3.81) * [1 0 0, 1 0 0, 1 0 0, 1 0 0] + [-0.45 -2 8.1, 0.45 -2 8.1, 0.45 2 8.1, -0.45 2 8.1];
    H = [H, H + [0 0 -1, 0 0 -1, 0 0 -1, 0 0 -1]];
    fprintf(fid, 'in metal%dh.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', [nrT + i, H]);
end

% join regions
fprintf(fid, 'r metals.r');
for i = 1 : 2 * nrT
    fprintf(fid, ' u metal%ds.s', i);
end
fprintf(fid, '\n');

fprintf(fid, 'r metalh.r');
for i = 1 : 2 * nrT
    fprintf(fid, ' u metal%dh.s', i);
end
fprintf(fid, '\n');



%% Create the model
fprintf(fid, 'comb body.C u bodys.r - bodyh.r\n');
fprintf(fid, 'comb metal.C u metals.r - metalh.r\n');

fprintf(fid, 'mater body.C "plastic" 153 255 127 0\n');
fprintf(fid, 'mater metal.C "metal" 255 255 255 0\n');

%% Create servo
fprintf(fid, 'comb CBT0308.c u body.C u metal.C\n');
fclose(fid);


%% Render the wheel
unix(sprintf('%smged -c %s.g < %s.mged', folder, fn, fn));

for i = 15 : 15 : 360
    unix(sprintf('%srt -a -90 -e %g -w 200 -n 200 -C255/255/255 -o %s%03g.png %s.g arduino.c', folder, i, fn, i, fn));
end

unix(sprintf('convert -delay 20 -loop 0 %s???.png %s.gif', fn, fn));

unix(sprintf('chmod 644 %s???.png', fn));
unix(sprintf('rm %s???.png', fn));

%% Create and fix an STL file
unix(sprintf('%sg-stl -a 0.05 -o %s1.stl %s.g CBT0308.c', folder, fn, fn));
unix(sprintf('%sg-stl -a 0.05 -o metal1.stl %s.g metal.C', folder, fn));
unix(sprintf('%sg-stl -a 0.05 -o body1.stl %s.g body.C', folder, fn));

unix(sprintf('../meshconv -c stl body1.stl -o body'));
unix(sprintf('../meshconv -c stl metal1.stl -o metal'));
unix(sprintf('../meshconv -c stl %s1.stl -o %s', fn, fn));

%unix(sprintf('rm %s1.stl', fn));

