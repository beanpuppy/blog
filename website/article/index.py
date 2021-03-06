from simplerr.web import web, GET

from common.models.main import Article
from common.mdtohtml import MDtoHTML


@web('/article/<link>', '/article/templates/article_layout.html', GET)
def article(request, link):
    """Render article."""

    article = Article.get_article(link)
    p, n = article.get_prev_next()

    return {
        'link': link,
        'article': article,
        'previous': p or { 'title': None },
        'next': n or { 'title': None }
    }


@web('/article/preview/<link>', '/article/templates/article_layout.html', GET)
def article_preview(request, link):
    """Render wip article."""
    if not request.host.startswith('127.0.0.1'):
        raise  # das some shitty security right here

    article = MDtoHTML.convert_article(link)

    return {
        'article': article,
        'previous': { 'title': None },
        'next': { 'title': None }
    }


@web('/article/static/img/<path:file>', file=True)
def images(request, file):
    # Also added a website route so can see images on GitHub when previewing the mardown article
    return './article/static/img/' + file
