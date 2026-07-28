import Testing
@testable import MyBangumi

struct CommunityRoadmapTests {
    @Test func roadmapKeepsRecommendationLocalAndDefersDiscussionBackend() {
        #expect(CommunityRoadmap.recommendationStrategy.requiresCustomBackend == false)
        #expect(CommunityRoadmap.discussionStrategy.requiresCustomBackend == true)
        #expect(CommunityRoadmap.recommendationStrategy.dataSources.contains(.bangumiCollections))
        #expect(CommunityRoadmap.discussionStrategy.risk.contains("内容审核"))
    }
}
