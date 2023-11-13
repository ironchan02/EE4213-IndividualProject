import string
from nltk.stem.porter import PorterStemmer
from nltk import word_tokenize
from nltk.stem.porter import PorterStemmer

porter = PorterStemmer()


comment = "The best games are the classic ones like this! Always a family favorite!"

filterComment = comment.lower()
filterComment = "".join([char for char in filterComment if char not in string.punctuation])
filterComment = word_tokenize(filterComment)
filterComment = [porter.stem(word) for word in filterComment]
filterComment = " ".join(filterComment)

print("Before: " + comment)
print("After: " + filterComment)

