fn = 'coil';
folder = '/usr/brlcad/bin/';

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');

%% Coil body
H = [-4.95 -5.15 4, 4.95 -5.15 4, 4.95 5.15 4 -4.95 5.15 4];
H = [H, H - [0 0 3.95, 0 0 3.95, 0 0 3.95, 0 0 3.95]];
fprintf(fid, 'in F1.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);


H = [-5.45 -4.65 4, 5.45 -4.65 4, 5.45 4.65 4 -5.45 4.65 4];
H = [H, H - [0 0 3.95, 0 0 3.95, 0 0 3.95, 0 0 3.95]];
fprintf(fid, 'in F2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);



H = [-4.95, -4.65, 0.05, 0, 0, 3.95, 0.5];
fprintf(fid, 'in F3.s rcc %g %g %g   %g %g %g   %g\n', H);

H = [4.95, -4.65, 0.05, 0, 0, 3.95, 0.5];
fprintf(fid, 'in F4.s rcc %g %g %g   %g %g %g   %g\n', H);

H = [-4.95, 4.65, 0.05, 0, 0, 3.95, 0.5];
fprintf(fid, 'in F5.s rcc %g %g %g   %g %g %g   %g\n', H);

H = [4.95, 4.65, 0.05, 0, 0, 3.95, 0.5];
fprintf(fid, 'in F6.s rcc %g %g %g   %g %g %g   %g\n', H);

%% Coil tabs
H = [-5.6 -2 3, -2 -2 3, -2 2 3 -5.6 2 3];
H = [H, H - [0 0 3, 0 0 3, 0 0 3, 0 0 3]];
fprintf(fid, 'in T1.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
H = [2 -2 3, 5.6 -2 3, 5.6 2 3 2 2 3];
H = [H, H - [0 0 3, 0 0 3, 0 0 3, 0 0 3]];
fprintf(fid, 'in T2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

%% Create the model
fprintf(fid, 'comb F.C u F1.s u F2.s u F3.s u F4.s u F5.s u F6.s\n');
fprintf(fid, 'r T.r u T1.s u T2.s\n');
fprintf(fid, 'comb T.C u T.r - F.C\n');
fprintf(fid, 'mater F.C "plastic" 0 0 0 0\n');
fprintf(fid, 'mater T.C "metal" 255 255 255 0\n');

%% Create servo
fprintf(fid, 'comb coil.c u F.C u T.C\n');
fclose(fid);


%% Render the wheel
unix(sprintf('%smged -c %s.g < %s.mged', folder, fn, fn));

for i = 15 : 15 : 360
    unix(sprintf('%srt -a -90 -e %g -w 200 -n 200 -C255/255/255 -o %s%03g.png %s.g coil.c', folder, i, fn, i, fn));
end

unix(sprintf('convert -delay 20 -loop 0 %s???.png %s.gif', fn, fn));

unix(sprintf('chmod 644 %s???.png', fn));
unix(sprintf('rm %s???.png', fn));

%% Create and fix an STL file
unix(sprintf('%sg-stl -a 0.005 -o %s.stl %s.g coil.c', folder, fn, fn));

