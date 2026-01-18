import React from 'react';
import { Calendar, Clock, ArrowRight, User } from 'lucide-react';
import { Link } from 'react-router-dom';

const Blog = () => {
    const featuredPost = {
        id: 1,
        title: 'The Science Behind Gamified Learning: Why It Works',
        excerpt: 'Discover how game mechanics tap into the brain\'s reward system to create lasting educational experiences that children actually enjoy.',
        image: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
        category: 'Research',
        author: 'Dr. Sarah Mitchell',
        date: 'Jan 15, 2026',
        readTime: '8 min read',
    };

    const blogPosts = [
        {
            id: 2,
            title: '10 Ways to Keep Your Child Engaged in Online Learning',
            excerpt: 'Practical tips for parents to maintain their child\'s motivation and focus during digital education sessions.',
            image: 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=400',
            category: 'Parenting',
            author: 'Emily Chen',
            date: 'Jan 12, 2026',
            readTime: '5 min read',
        },
        {
            id: 3,
            title: 'Building Emotional Intelligence in Children Through Play',
            excerpt: 'How structured play activities can help children develop crucial emotional and social skills.',
            image: 'https://images.unsplash.com/photo-1544776193-352d25ca82cd?w=400',
            category: 'Development',
            author: 'Michael Torres',
            date: 'Jan 10, 2026',
            readTime: '6 min read',
        },
        {
            id: 4,
            title: 'The Future of EdTech: Trends to Watch in 2026',
            excerpt: 'From AI tutors to VR classrooms, explore the technologies shaping the future of education.',
            image: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400',
            category: 'Technology',
            author: 'Alex Kim',
            date: 'Jan 8, 2026',
            readTime: '7 min read',
        },
        {
            id: 5,
            title: 'Why Mindfulness Matters for Young Learners',
            excerpt: 'Exploring the benefits of incorporating breathing exercises and meditation into children\'s daily routines.',
            image: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400',
            category: 'Wellness',
            author: 'Dr. Lisa Park',
            date: 'Jan 5, 2026',
            readTime: '4 min read',
        },
        {
            id: 6,
            title: 'How to Choose the Right Learning App for Your Child',
            excerpt: 'A comprehensive guide to evaluating educational apps and finding the perfect fit for your family.',
            image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
            category: 'Guide',
            author: 'James Wilson',
            date: 'Jan 3, 2026',
            readTime: '6 min read',
        },
        {
            id: 7,
            title: 'The Power of Vocabulary: Building Strong Readers',
            excerpt: 'Research-backed strategies for expanding your child\'s vocabulary and reading comprehension.',
            image: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400',
            category: 'Education',
            author: 'Rachel Green',
            date: 'Dec 28, 2025',
            readTime: '5 min read',
        },
        {
            id: 8,
            title: 'Screen Time Done Right: Quality Over Quantity',
            excerpt: 'How to make every minute of screen time count with purposeful, educational content.',
            image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
            category: 'Parenting',
            author: 'David Brown',
            date: 'Dec 25, 2025',
            readTime: '4 min read',
        },
        {
            id: 9,
            title: 'Creating a Learning-Friendly Home Environment',
            excerpt: 'Simple changes you can make to transform your home into an inspiring space for education.',
            image: 'https://images.unsplash.com/photo-1497493292307-31c376b6e479?w=400',
            category: 'Tips',
            author: 'Sophie Adams',
            date: 'Dec 22, 2025',
            readTime: '5 min read',
        },
    ];

    const categories = ['All', 'Research', 'Parenting', 'Development', 'Technology', 'Wellness', 'Education'];

    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-7xl mx-auto">
            {/* Header */}
            <div className="text-center mb-16">
                <h1 className="text-5xl md:text-6xl font-bold text-text-primary mb-4">
                    Lifemonk Blog
                </h1>
                <p className="text-xl text-text-secondary max-w-2xl mx-auto">
                    Insights, tips, and research on childhood education, development, and the future of learning.
                </p>
            </div>

            {/* Categories */}
            <div className="flex flex-wrap gap-3 justify-center mb-12">
                {categories.map((cat) => (
                    <button
                        key={cat}
                        className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${cat === 'All'
                            ? 'bg-primary-light text-white'
                            : 'bg-gray-100 dark:bg-gray-800 text-text-secondary hover:bg-primary-light/10 hover:text-primary-DEFAULT'
                            }`}
                    >
                        {cat}
                    </button>
                ))}
            </div>

            {/* Featured Post */}
            <div className="mb-16">
                <div className="relative rounded-3xl overflow-hidden bg-gradient-to-r from-primary-light to-blue-600">
                    <div className="grid grid-cols-1 lg:grid-cols-2">
                        <div className="p-8 md:p-12 flex flex-col justify-center">
                            <span className="inline-block px-3 py-1 bg-white/20 text-white text-sm font-medium rounded-full w-fit mb-4">
                                Featured
                            </span>
                            <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                                {featuredPost.title}
                            </h2>
                            <p className="text-white/80 mb-6">{featuredPost.excerpt}</p>
                            <div className="flex items-center gap-4 text-white/70 text-sm mb-6">
                                <span className="flex items-center gap-1">
                                    <User className="w-4 h-4" />
                                    {featuredPost.author}
                                </span>
                                <span className="flex items-center gap-1">
                                    <Calendar className="w-4 h-4" />
                                    {featuredPost.date}
                                </span>
                                <span className="flex items-center gap-1">
                                    <Clock className="w-4 h-4" />
                                    {featuredPost.readTime}
                                </span>
                            </div>
                            <Link
                                to={`/blog/${featuredPost.id}`}
                                className="inline-flex items-center gap-2 text-white font-semibold hover:gap-3 transition-all"
                            >
                                Read Article <ArrowRight className="w-5 h-5" />
                            </Link>
                        </div>
                        <div className="hidden lg:block">
                            <img
                                src={featuredPost.image}
                                alt={featuredPost.title}
                                className="w-full h-full object-cover"
                            />
                        </div>
                    </div>
                </div>
            </div>

            {/* Blog Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {blogPosts.map((post) => (
                    <article
                        key={post.id}
                        className="bg-white dark:bg-gray-900 rounded-2xl overflow-hidden border border-gray-100 dark:border-gray-800 hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
                    >
                        <div className="aspect-video overflow-hidden">
                            <img
                                src={post.image}
                                alt={post.title}
                                className="w-full h-full object-cover hover:scale-105 transition-transform duration-500"
                            />
                        </div>
                        <div className="p-6">
                            <span className="inline-block px-3 py-1 bg-primary-light/10 text-primary-DEFAULT text-xs font-medium rounded-full mb-3">
                                {post.category}
                            </span>
                            <h3 className="text-lg font-bold text-text-primary mb-2 line-clamp-2 hover:text-primary-DEFAULT transition-colors">
                                <Link to={`/blog/${post.id}`}>{post.title}</Link>
                            </h3>
                            <p className="text-text-secondary text-sm mb-4 line-clamp-2">
                                {post.excerpt}
                            </p>
                            <div className="flex items-center justify-between text-xs text-text-tertiary">
                                <span className="flex items-center gap-1">
                                    <User className="w-3 h-3" />
                                    {post.author}
                                </span>
                                <span className="flex items-center gap-1">
                                    <Clock className="w-3 h-3" />
                                    {post.readTime}
                                </span>
                            </div>
                        </div>
                    </article>
                ))}
            </div>

            {/* Load More */}
            <div className="text-center mt-12">
                <button className="px-8 py-3 bg-gray-100 dark:bg-gray-800 text-text-primary rounded-xl font-semibold hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
                    Load More Articles
                </button>
            </div>
        </div>
    );
};

export default Blog;
