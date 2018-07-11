using Galena
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

# write your own tests here
@test 1 == 2


using Images

img1 = load("test/test.png");
img2 = load("test/test2.png");
# img2 = load("test/test.png");
img1 == img2
