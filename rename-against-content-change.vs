on master => perform {
    add file => "this is the one file";
    commit "the file"
};

branch master => other;

on other => perform {
    move file => new_file_name;
    commit "changed name"
};

on master => perform {
    change file => "this is one file";
    commit "not *the* only file"
};

merge other => master;
