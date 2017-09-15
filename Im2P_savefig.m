DIR = 'C:\Users\Dudi\Dropbox\My Documents\PostDoc\Post doc- Research\Group meetings\03032017 - Dudi 7th presentation\';
filename = 'CaExample_MaleSine200';
handle = gcf;

SaveTo = [DIR,filename,'.fig'];
savefig(handle, SaveTo)
SaveTo = [DIR,filename,'.pdf'];
save2pdf(SaveTo,handle,2400)

